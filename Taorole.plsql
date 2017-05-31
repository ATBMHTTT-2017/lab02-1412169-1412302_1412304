--Cau2: Tao role cho cac vi tri cua cty
create role GiamDoc; -- Giam doc
create role Truong_CN_CTY; -- Truong chi nhanh cua cty
create role Truong_Phong_CTY; -- Truong phong 
create role Truong_DA_CTY; -- Truong DA
create role NV_BT_CTY; -- Nhan vien binh thuong
create role ThamGia_DeAn;

grant create session to GiamDoc, Truong_CN_CTY, Truong_Phong_CTY, Truong_DA_CTY, NV_BT_CTY, ThamGia_DeAn;

grant GiamDoc to NV000;
grant Truong_CN_CTY to NV001, NV101, NV201, NV301, NV401;
grant Truong_Phong_CTY to NV011, NV021, NV031, NV041, NV111, NV121, NV131, NV141, NV211, NV221, NV231, NV241, NV311, NV321, NV331, NV411, NV421, NV431;
grant Truong_DA_CTY to NV112, NV212, NV142, NV332, NV422;
grant NV_BT_CTY to NV012, NV022, NV042, NV043, NV113, NV122, NV143, NV213, NV232, NV243, NV333;
grant ThamGia_DeAn to NV113, NV143, NV243, NV333;
