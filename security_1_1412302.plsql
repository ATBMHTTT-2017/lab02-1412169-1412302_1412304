set serveroutput on
CREATE OR REPLACE PROCEDURE THEM_NV
(
  NV in VARCHAR2,
  TEN in VARCHAR2,
  DC in VARCHAR2,
  DT in VARCHAR2,
  MAIL in VARCHAR2,
  PHONG in VARCHAR2,
  CN in VARCHAR2,
  luong in VARCHAR2
) AS 
BEGIN
 Declare
    input_string      VARCHAR(200) := LUONG;
    --output_string      RAW(2000);
    encrypted_raw     RAW(2000);
    num_key_bytes      NUMBER := 256/8;
    key_bytes_raw      RAW(32);
   encryption_type   PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256
                                    + DBMS_CRYPTO.CHAIN_CBC
                                    + DBMS_CRYPTO.PAD_PKCS5;
  Begin
    DBMS_OUTPUT.PUT_LINE ('Original string: ' || input_string);
    key_bytes_raw := DBMS_CRYPTO.RANDOMBYTES (num_key_bytes);
    
    encrypted_raw := DBMS_CRYPTO.ENCRYPT (
                                          src => UTL_I18N.STRING_TO_RAW (input_string,'AL32UTF8'),
                                          typ => encryption_type,
                                          key => key_bytes_raw
                                          );
  insert into NHANVIEN values(NV, TEN, DC, DT, MAIL, PHONG, CN, encrypted_raw, key_bytes_raw);
  commit;
  End;
END THEM_NV;

CREATE OR REPLACE PROCEDURE XemLuong
AS
  output_string VARCHAR2(2000);
  decrypted_raw     RAW(2000); 
  maNV varchar2(5) := sys_context ('userenv', 'session_user');
  encryption_type   PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256
                                  + DBMS_CRYPTO.CHAIN_CBC
                                  + DBMS_CRYPTO.PAD_PKCS5;                                                     
BEGIN
  for NhanVien in (select * from NhanVien)
  loop  
  if  UPPER(NHANVIEN.MANV) = maNV then 
  decrypted_raw := DBMS_CRYPTO.DECRYPT (
                                        src => NhanVien.Luong,
                                        typ =>  encryption_type,
                                        key => NhanVien.Key);                                   
  output_string := UTL_I18N.RAW_TO_CHAR (decrypted_raw, 'AL32UTF8');
  dbms_output.put_line('> Your Salary is: ' || output_string);
  end if;
  end loop;
END XemLuong;

GRANT execute on Xemluong to GiamDoc, Truong_CN_CTY, Truong_Phong_CTY, Truong_DA_CTY, NV_BT_CTY;