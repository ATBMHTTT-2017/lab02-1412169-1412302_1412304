alter TABLE CHITIEU drop column sotien;
alter TABLE CHITIEU add encrypt_sotien raw(2000);
create or replace function encrypted_data(
  input_data in number,
	public_key in CLOB
)
return RAW
AS
encrypt_data RAW(2000);
BEGIN 
--
  -- RSA Encrypt
  encrypt_data := ORA_RSA.ENCRYPT(message => UTL_I18N.STRING_TO_RAW(input_data, 'AL32UTF8'),
                             public_key => UTL_RAW.CAST_TO_RAW(public_key));
    return encrypt_data;
EXCEPTION
   -- ORA_RSA exception handling 
   WHEN ORA_RSA.RSA_EXCEPTION THEN
     BEGIN
       IF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_WRONG_PASSWORD_ERR THEN
         DBMS_OUTPUT.PUT_LINE('The password for the private key is not matching: ' || SQLERRM);
       ELSIF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_KEY_ERR THEN
         DBMS_OUTPUT.PUT_LINE('The provided key is not a valid RSA key.');
       ELSIF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_ENCRYPTION_ERR THEN
         DBMS_OUTPUT.PUT_LINE('Error when performing RSA operation: ' || SQLERRM);
       ELSIF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_GENERAL_IO_ERR THEN
         DBMS_OUTPUT.PUT_LINE('I/O error: ' || SQLERRM);
       END IF;
     END;

   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('General error : ' || SQLERRM );
END;




create or replace procedure decrypted_data(
  encrypt_data in RAW,
	private_key in CLOB)
AS
decrypt_data RAW(2000);
BEGIN
--
  -- RSA Decrypt
  decrypt_data := ORA_RSA.DECRYPT(encrypt_data, UTL_RAW.CAST_TO_RAW(private_key));
  
  
  DBMS_OUTPUT.put_line(UTL_I18N.RAW_TO_CHAR(decrypt_data, 'AL32UTF8'));  
EXCEPTION
   -- ORA_RSA exception handling 
   WHEN ORA_RSA.RSA_EXCEPTION THEN
     BEGIN
       IF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_WRONG_PASSWORD_ERR THEN
         DBMS_OUTPUT.PUT_LINE('The password for the private key is not matching: ' || SQLERRM);
       ELSIF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_KEY_ERR THEN
         DBMS_OUTPUT.PUT_LINE('The provided key is not a valid RSA key.');
       ELSIF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_ENCRYPTION_ERR THEN
         DBMS_OUTPUT.PUT_LINE('Error when performing RSA operation: ' || SQLERRM);
       ELSIF ORA_RSA.GET_RSA_ERROR() = ORA_RSA.RSA_GENERAL_IO_ERR THEN
         DBMS_OUTPUT.PUT_LINE('I/O error: ' || SQLERRM);
       END IF;
     END;

   WHEN OTHERS THEN
     DBMS_OUTPUT.PUT_LINE('General error : ' || SQLERRM );
END;


create or replace procedure Ins_ChiTieu (
 machitieu in varchar2,
 tenchitieu in varchar2,
 sotien in number,
 maduan in varchar2,
 public_key in clob
)
AS
BEGIN
  insert into ChiTieu values (machitieu, tenchitieu, maduan, encrypted_data(sotien, public_key));
  commit;
END;

create or replace procedure Sele_ChiTieu(
  maduan in varchar2,
  private_key in clob
)
AS
BEGIN
  for ct in (select * from ChiTieu)
  loop
  if ct.duan = maduan then
  DBMS_OUTPUT.PUT_LINE('Ma chi tieu: ' || ct.machitieu );
  DBMS_OUTPUT.PUT('So tien: ');
  decrypted_data(ct.encrypt_sotien, private_key);
  end if;
  end loop;
END;

GRANT execute on encrypted_data to Truong_DA_CTY;
GRANT execute on decrypted_data to Truong_DA_CTY;
GRANT execute on INS_CHITIEU to Truong_DA_CTY;
GRANT execute on SELE_CHITIEU to NV111; 

---Phần thực thi dành cho những user là trưởng đề án

declare public_key clob := '-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCTlRzFkKRlk4kexec91kCCLyW
FA7m2QD1Mc49jYK4qJoZ6MI4IiuNENlDzcYAat8JTITKQKdNfjq+kdppDnLTmeeU
I4Jtlc06L1uDLji1hgeN315t6g3tOf0iHVdyt4dilcHDannCU0duU0TXhh6OK/HH
HtwZ7lcxCo5NgzUDlwIDAQAB
-----END PUBLIC KEY-----';
BEGIN
sys_bt2_demo.INS_CHITIEU ('CT117', 'Thuc pham chuc nang', 1000000, 'DA101', public_key);
END;

---Phần thực thi dành cho những user được phép giải mã thông tin

declare
  private_key clob := '-----BEGIN PRIVATE KEY-----
MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMJOVHMWQpGWTiR7
F5z3WQIIvJYUDubZAPUxzj2NgriomhnowjgiK40Q2UPNxgBq3wlMhMpAp01+Or6R
2mkOctOZ55Qjgm2VzTovW4MuOLWGB43fXm3qDe05/SIdV3K3h2KVwcNqecJTR25T
RNeGHo4r8cce3BnuVzEKjk2DNQOXAgMBAAECgYEAuqIMQaL+++IYWrgU/UMkLmz/
31OS4K9NWTamt77F8eKYagyFCO/hTxUA6zyqU9pTMxZZcf9Z83gsqsFjvYcQSHy6
mRXFuORzh0r/wXKJtyFF0B26KC7WipqtPAuzn7SNGNeMh8g3H1qH8neEjir15Uai
6lR/sDIOZlO9sUJoZBECQQDkLXnXl/YXGoQDdupUQMzrF+ZK/od2U9YjdSOi+k/j
x23usurtzRhYGW/73vJd9Sw6Qc6ijPr+ItSpnl+qaxzvAkEA2f+OVzn1HwmYbc2a
Booo32aT96TJrwN8V4gC7m5hseHoXDDoXmwLZwNm7+w0vu3lk1p9tSqs8oc/nR0E
fHhT2QJAOQslasCSxTPbzQHtkyKgGCXhbN40/1/2KOcgAZ6SWl+BHCuej9S2QVAa
rt0Num+Qnv/UqM6V8PLEN6NgRzqAAQJBALeQYrp+WjKNcOYc97LECdC73qLsBswx
QjWumNFO70LLOE7Q/AnuLtfKXJZwrqWLSwJ+c1XnHoSGcIGK2qk45VkCQA6b1qCv
jGFksgcQ8vff5lwOWfJ2ZxA8Zpgeq5w7EaDTWS/WhtVUYg3bBsadgXb3LxpZScxq
U4Ad7pAZrI6H6Tc=
-----END PRIVATE KEY-----';
BEGIN
 sys_bt2_demo.SELE_CHITIEU('DA101', private_key);
END;