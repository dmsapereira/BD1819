-- Table Resetting
drop table providers cascade constraints;
drop table stands cascade constraints;
drop table cars cascade constraints;
drop table models cascade constraints;
drop table fuel_models cascade constraints;
drop table eletric_models cascade constraints;
drop table clients cascade constraints;
drop table insurance_companies cascade constraints;
drop table sellers cascade constraints;
drop table insurance_agents cascade constraints;
drop table supplies cascade constraints;
drop table sales cascade constraints;

--Table Creation
create table providers(
    provider_name varchar2(30)
);

create table stands(
    stand_name varchar2(30),
    city varchar2(20)
);

create table cars(
    license_plate varchar2(6),
    origin_stand varchar2(30),
    model_name varchar2(20),
);

create table cars_availability(
    license_plate varchar(6),
    state varchar2(10)
);

create table models(
    model_name varchar2(20),
    horsepower number(4,0),
    price number(12, 0),
    brand_name varchar2(20)
);

create table fuel_models(
    model_name varchar2(20),
    fuel_type varchar2(10),
    consumption number(3, 1),
    engine_size number(5, 0)
);

create table eletric_models(
    model_name varchar2(20),
    autonomy number (5,0)
);

create table clients(
    nif varchar2(10),
    client_name varchar2(50)
);

create table insurance_companies(
    company_name varchar2(20)
);

create table sellers(
    seller_id varchar2(10),
    seller_name varchar2(50),
    stand_name varchar2(30)
);

create table insurance_agents(
    agent_id varchar2(10),
    agent_name varchar2(50),
    company_name varchar2(20)
);

create table supplies(
    provider_name varchar2(30),
    stand_name varchar2(30),
    license_plate varchar2(6),
    date_of_supply date,
    supply_id varchar2(10)
);

create table sales(
    stand_name varchar2(30),
    company_name varchar2(30),
    nif varchar2(10),
    license_plate varchar2(6),
    seller_id varchar2(10),
    agent_id varchar2(10),
    payment_method varchar2(15),
    sale_date date,
    sale_id varchar2(10)
);

-- Primary Keys
alter table providers add constraint pk_provider primary key(provider_name);
alter table stands add constraint pk_stands primary key(stand_name);
alter table cars add constraint pk_cars primary key(license_plate);
alter table models add constraint pk_models primary key(model_name);
alter table clients add constraint pk_clients primary key(nif);
alter table insurance_companies add constraint pk_companies primary key(company_name);
alter table sellers add constraint pk_sellers primary key(seller_id, stand_name);
alter table insurance_agents add constraint pk_agents primary key(agent_id, company_name);
alter table supplies add constraint pk_supplies primary key(supply_id);
alter table sales add constraint pk_sales primary key(sale_id);

-- Foreign Keys
alter table cars add constraint fk_cars_stand foreign key (origin_stand) references stands(stand_name);
alter table cars add constraint fk_cars_model foreign key (model_name) references models(model_name);

alter table cars_availability add constraint fk_availability_car foreign key (license_plate) references cars(license_plate);

alter table fuel_models add constraint fk_fuels_model foreign key (model_name) references models(model_name);
alter table eletric_models add constraint fk_eletrics_model foreign key (model_name) references models(model_name);

alter table sellers add constraint fk_sellers_stand foreign key (stand_name) references stands(stand_name);

alter table insurance_agents add constraint fk_agents_company foreign key (company_name) references insurance_companies(company_name);

alter table supplies add constraint fk_supplies_provider foreign key (provider_name) references providers(provider_name);
alter table supplies add constraint fk_supplies_stand foreign key (stand_name) references stands(stand_name);
alter table supplies add constraint fk_supplies_license_plate foreign key (license_plate) references cars(license_plate);

alter table sales add constraint fk_sales_stand foreign key (stand_name) references stands(stand_name);
alter table sales add constraint fk_sales_insurance_company foreign key (company_name) references insurance_companies(company_name);
alter table sales add constraint fk_sales_nif foreign key (nif) references clients(nif);
alter table sales add constraint fk_sales_license_plate foreign key (license_plate) references cars(license_plate);
alter table sales add constraint fk_sales_seller foreign key (seller_id, stand_name) references sellers(seller_id, stand_name);
alter table sales add constraint fk_sales_agent foreign key(agent_id, company_name) references insurance_agents(agent_id, company_name);

-- Uniques

-- Checks
alter table cars_availability add constraint state_check check(state = 'Vendido' OR state = 'Disponivel');

alter table models add constraint hp_check check(horsepower > 0);
alter table models add constraint price_check check(price > 0);

alter table fuel_models add constraint fuel_check check(fuel_type = 'Gasolina' OR fuel_type = 'Gasoleo' OR fuel_type = 'GPL' OR fuel_type = 'Hidrogeneo'OR fuel_type = 'Agricola');
alter table fuel_models add constraint consumption_check check(consumption > 0);
alter table fuel_models add constraint engine_check check(engine_size > 0);

alter table eletric_models add constraint autonomy_check check(autonomy > 0);

alter table sales add constraint p_method_check check(payment_method = 'Multibanco' OR payment_method = 'Dinheiro' OR payment_method = 'Criptomoeda' OR payment_method = 'Cheque');

--Triggers

create or replace trigger novo_carro
  after insert on carros
  declare license varchar2(6);
  begin
    select license_plate into license
    from carros
    where license_plate = :new.license_plate;
    insert into cars_availability values(license_plate, 'Disponivel');
  end;
/

create or replace trigger carro_vendido
  after insert on sales
  declare license varchar2(6);
  begin
    select license_plate into license
    from :new;
    update cars_availability
    set state = 'Vendido'
    where license_plate = license;
  end;
  /
