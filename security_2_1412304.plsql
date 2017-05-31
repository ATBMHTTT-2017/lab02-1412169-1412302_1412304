declare
  public_key clob := '-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCTlRzFkKRlk4kexec91kCCLyW
FA7m2QD1Mc49jYK4qJoZ6MI4IiuNENlDzcYAat8JTITKQKdNfjq+kdppDnLTmeeU
I4Jtlc06L1uDLji1hgeN315t6g3tOf0iHVdyt4dilcHDannCU0duU0TXhh6OK/HH
HtwZ7lcxCo5NgzUDlwIDAQAB
-----END PUBLIC KEY-----';

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

create or replace function create_digital_signature (
  input_data in number,
	private_key in CLOB
)
return RAW
AS
signature RAW(2000);
BEGIN 
--
    -- RSA SIGN
    --
    signature := ORA_RSA.SIGN(message => UTL_I18N.STRING_TO_RAW(input_data, 'AL32UTF8'),
                                      private_key => UTL_RAW.cast_to_raw(private_key),
                                      hash => ORA_RSA.HASH_SHA256);
    return signature;
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

create or replace procedure verify(
  input_data in number,
	public_key in CLOB,
  signature in RAW)
AS
  signature_check_result PLS_INTEGER;
BEGIN
--
    -- RSA VERIFY
    --
    signature_check_result := ORA_RSA.VERIFY(message => UTL_I18N.STRING_TO_RAW(input_data, 'AL32UTF8'), 
                                             signature => signature, 
                                             public_key => UTL_RAW.cast_to_raw(public_key),
                                             hash => ORA_RSA.HASH_SHA256);
  
    IF signature_check_result = 1 Then
       DBMS_OUTPUT.put_line('Signature verification passed.'); 
    ELSE
       DBMS_OUTPUT.put_line('Signature cannot be verified!'); 
    END IF;   
	
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
sig raw(2000);
begin
for PC in (select * from PHANCONG)
  loop  
  sig:=create_digital_signature(PC.PHUCAP,private_key); 
  UPDATE PHANCONG SET signature=sig WHERE manv=PC.MANV;
  COMMIT;
  end loop;
end;

grant select on PhanCong to ThamGia_DeAn;
grant execute on verify to ThamGia_DeAn;

declare
public_key clob := '-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDCTlRzFkKRlk4kexec91kCCLyW
FA7m2QD1Mc49jYK4qJoZ6MI4IiuNENlDzcYAat8JTITKQKdNfjq+kdppDnLTmeeU
I4Jtlc06L1uDLji1hgeN315t6g3tOf0iHVdyt4dilcHDannCU0duU0TXhh6OK/HH
HtwZ7lcxCo5NgzUDlwIDAQAB
-----END PUBLIC KEY-----';
begin
for PC in (select * from sys_bt2_demo.PHANCONG)
  loop  
  if PC.MANV=sys_context ('userenv', 'session_user') then 
  sys_bt2_demo.verify(PC.PHUCAP,public_key,PC.signature); 
  end if;
  end loop;
end;
