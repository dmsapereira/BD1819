-- Table Resetting
drop table providers cascade constraints;
drop table stands cascade constraints;
drop table cars cascade constraints;
drop table cars_availability cascade constraints;
drop table models cascade constraints;
drop table fuel_models cascade constraints;
drop table eletric_models cascade constraints;
drop table clients cascade constraints;
drop table insurance_companies cascade constraints;
drop table sellers cascade constraints;
drop table insurance_agents cascade constraints;
drop table supplies cascade constraints;
drop table sales cascade constraints;
drop sequence seq_sale_id;
drop sequence seq_agent_id;
drop sequence seq_model_id;
drop sequence seq_stand_id;
drop sequence seq_supply_id;
drop sequence seq_company_id;
drop sequence seq_provider_id;
drop sequence seq_seller_id;

--Sequences
create sequence seq_provider_id
start with 1
increment by 1;


create sequence seq_stand_id
start with 1
increment by 1;

create sequence seq_seller_id
start with 1
increment by 1;

create sequence seq_model_id
start with 1
increment by 1;


create sequence seq_company_id
start with 1
increment by 1;

create sequence seq_agent_id
start with 1
increment by 1;

create sequence seq_supply_id
start with 1
increment by 1;

create sequence seq_sale_id
start with 1
increment by 1;
--Table Creation
create table providers(
    provider_name varchar2(30),
    provider_id varchar(10)
);

create table stands(
    stand_name varchar2(30),
    stand_id varchar2(10),
    city varchar2(20)
);

create table cars(
    license_plate varchar2(6),
    stand_id varchar2(10),
    model_id varchar2(10)
);

create table cars_availability(
    license_plate varchar(6),
    state varchar2(10)
);

create table models(
    model_name varchar2(20),
    model_id varchar2(10),
    horsepower number(4,0),
    price number(12, 0),
    brand_name varchar2(20)
);

create table fuel_models(
    model_id varchar2(10),
    fuel_type varchar2(10),
    consumption number(3, 1),
    engine_size number(5, 0)
);

create table eletric_models(
    model_id varchar2(10),
    autonomy number (5,0)
);

create table clients(
    client_name varchar2(50),
    nif varchar2(10)
);

create table insurance_companies(
    company_name varchar2(20),
    company_id varchar2(10)
);

create table sellers(
    seller_name varchar2(50),
    seller_id varchar2(10),
    stand_id varchar2(10)
);

create table insurance_agents(
    agent_name varchar2(50),
    agent_id varchar2(10),
    company_id varchar2(10)
);

create table supplies(
    provider_id varchar2(30),
    stand_id varchar2(30),
    license_plate varchar2(6),
    date_of_supply date,
    supply_id varchar2(10)
);

create table sales(
    stand_id varchar2(10),
    seller_id varchar2(10),
    company_id varchar2(10),
    agent_id varchar2(10),
    license_plate varchar2(6),
    nif varchar2(10),
    payment_method varchar2(15),
    sale_date date,
    sale_id varchar2(10)
);

-- Primary Keys
alter table providers add constraint pk_provider primary key(provider_id);
alter table stands add constraint pk_stands primary key(stand_id);
alter table cars add constraint pk_cars primary key(license_plate);
alter table models add constraint pk_models primary key(model_id);
alter table clients add constraint pk_clients primary key(nif);
alter table insurance_companies add constraint pk_companies primary key(company_id);
alter table sellers add constraint pk_sellers primary key(seller_id, stand_id);
alter table insurance_agents add constraint pk_agents primary key(agent_id, company_id);
alter table supplies add constraint pk_supplies primary key(supply_id);
alter table sales add constraint pk_sales primary key(sale_id);

-- Foreign Keys
alter table cars add constraint fk_cars_stand foreign key (stand_id) references stands(stand_id);
alter table cars add constraint fk_cars_model foreign key (model_id) references models(model_id);

alter table cars_availability add constraint fk_availability_car foreign key (license_plate) references cars(license_plate);

alter table fuel_models add constraint fk_fuels_model foreign key (model_id) references models(model_id);
alter table eletric_models add constraint fk_eletrics_model foreign key (model_id) references models(model_id);

alter table sellers add constraint fk_sellers_stand foreign key (stand_id) references stands(stand_id);

alter table insurance_agents add constraint fk_agents_company foreign key (company_id) references insurance_companies(company_id);

alter table supplies add constraint fk_supplies_provider foreign key (provider_id) references providers(provider_id);
alter table supplies add constraint fk_supplies_stand foreign key (stand_id) references stands(stand_id);
alter table supplies add constraint fk_supplies_license_plate foreign key (license_plate) references cars(license_plate);

alter table sales add constraint fk_sales_stand foreign key (stand_id) references stands(stand_id);
alter table sales add constraint fk_sales_insurance_company foreign key (company_id) references insurance_companies(company_id);
alter table sales add constraint fk_sales_nif foreign key (nif) references clients(nif);
alter table sales add constraint fk_sales_license_plate foreign key (license_plate) references cars(license_plate);
alter table sales add constraint fk_sales_seller foreign key (seller_id, stand_id) references sellers(seller_id, stand_id);
alter table sales add constraint fk_sales_agent foreign key(agent_id, company_id) references insurance_agents(agent_id, company_id);

-- Uniques

-- Checks
alter table cars_availability add constraint state_check check(state = 'Sold' OR state = 'Available');

alter table models add constraint hp_check check(horsepower > 0);
alter table models add constraint price_check check(price > 0);

alter table fuel_models add constraint fuel_check check(fuel_type = 'Gas' OR fuel_type = 'Diesel' OR fuel_type = 'GPL');
alter table fuel_models add constraint consumption_check check(consumption > 0);
alter table fuel_models add constraint engine_check check(engine_size > 0);

alter table eletric_models add constraint autonomy_check check(autonomy > 0);

alter table sales add constraint p_method_check check(payment_method = 'Multibanco' OR payment_method = 'Dinheiro' OR payment_method = 'Criptomoeda' OR payment_method = 'Cheque');

--Triggers
create or replace trigger car_sold
  after insert on sales
  for each row
    begin
      update cars_availability
      set state = 'Vendido'
      where license_plate = :NEW.license_plate;
    end;
  /
