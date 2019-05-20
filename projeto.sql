-- Table Resetting

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
    model_name varchar2(20)
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
    consumption number(2, 1),
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
    nif varchar2(10),
    license_plate varchar2(6),
    seller_id varchar2(10),
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
alter table cars add constraint fk_cars_stand foreign key (stand_name) references stands(stand_name);
alter table cars add constraint fk_cars_model foreign key (model_name) references models(model_name);

alter table fuel_models add constraint fk_fuels_model foreign key (model_name) references models(model_name);
alter table eletric_models add constraint fk_eletrics_model foreign key (model_name) references models(model_name);

alter table sellers add constraint fk_sellers_stand foreign key (stand_name) references stands(stand_name);

alter table insurance_agents add constraint fk_agents_company foreign key (company_name) references companies(company_name);

alter table supplies add constraint fk_supplies_provider foreign key (provider_name) references providers(provider_name);
alter table supplies add constraint fk_supplies_stand foreign key (stand_name) references stands(stand_name);
alter table supplies add constraint fk_supplies_license_plate foreign key (license_plate) references cars(license_plate);

alter table sales add constraint fk_sales_stand foreign key (stand_name) references stands(stand_name);
alter table sales add constraint fk_sales_nif foreign key (nif) references clients(nif);
alter table sales add constraint fk_sales_license_plate foreign key (license_plate) references cars(license_plate);
alter table sales add constraint fk_sales_seller foreign key (seller_id) references sellers(seller_id);





alter table matriculas add constraint un_mat unique(idCandidato);
-- Antes de referir a fk em matriculas é preciso indicar o unique em colocados
alter table colocados add constraint un_col unique(idCandidato,curso);
alter table matriculas add constraint fk_matrcolcurso foreign key (idCandidato,curso) references colocados(idCandidato,curso);

alter table planos add constraint fk_pcur foreign key (curso) references cursos(curso);
alter table planos add constraint fk_pcad foreign key (cadeira) references cadeiras(cadeira);

alter table matriculas add constraint un_matnumcur unique(numero,curso);
alter table inscricoes add constraint fk_inscurso foreign key (numero,curso) references matriculas(numero,curso);
alter table inscricoes add constraint fk_insplano foreign key (curso,cadeira) references planos(curso,cadeira);


-- Outras restricoes
alter table cadeiras add constraint numCred check(ects >= 3 and ects <=60);

-- 1.3

-- Criação prévia de sinónimos
create or replace synonym candidatos for candidaturas.candidatos;
create or replace synonym colocacoes for candidaturas.colocacoes;


-- Inserir os dados a partir de candidaturas
insert into cursos
  select curso, nomeCurso
  from candidaturas.cursos natural join candidaturas.ofertas
  where estab = '0903';

insert into colocados
  select idCandidato, nome, curso, 2017
  from candidatos inner join colocacoes using (idCandidato)
  where estab = '0903';
-- 1.5

drop sequence seq_num_aluno;

create sequence seq_num_aluno
start with 57000
increment by 1;

-- 1.6
insert into matriculas values (seq_num_aluno.nextval,112364,'G005',to_date('2017.09.10','YYYY.MM.DD'));
insert into matriculas values (seq_num_aluno.nextval,115680,'9209',to_date('2017.09.10','YYYY.MM.DD'));
insert into matriculas values (seq_num_aluno.nextval,115680,'G005',to_date('2017.09.10','YYYY.MM.DD'));
insert into matriculas values (seq_num_aluno.nextval,114332,'G005',to_date('2017.09.10','YYYY.MM.DD'));


-- 2.1
create or replace trigger inscreve_novo_aluno
	after insert on matriculas
	for each row
	begin
		insert into inscricoes
      select :new.numero, curso, cadeira, to_number(extract(year from :new.dataMatr)), :new.dataMatr
      from planos
      where curso = :new.curso and semestre = 1;
  end;
/

-- 2.2
-- Vamos testar matriculando o aluno 121107
insert into matriculas values (seq_num_aluno.nextval,121107,'G005',to_date('2017.09.10','YYYY.MM.DD'));


-- 3.1
-- Ajuda começar por ter uma view que a cada momento diz o nº de creditos a que cada aluno
-- está inscrito em cada ano
create or replace view totalCred as
    select numero, anoLetivo, sum(ects) as total
    from inscricoes I natural join cadeiras
    group by numero, anoLetivo;

-- Agora vamos adicionar um trigger que depois de cada inserção em inscricoes
-- verifica se não há nenhum aluno que ficou com mais de 72 créditos
create or replace trigger verifica_limite
  after insert on inscricoes
  declare NumECTS number;
  begin
    select max(total) into NumECTS from totalCred;
    if (NumECTS >  72)
      then Raise_Application_Error (-20100, 'Atingiu o limite de créditos. Inscrição não aceite!');
    end if;
  end;
/


-- 3.2

insert into inscricoes values (57004, 'G005', 10640, 2017, to_date('2017.09.10','YYYY.MM.DD'));
insert into inscricoes values (57004, 'G005', 11152, 2017, to_date('2017.09.10','YYYY.MM.DD'));
insert into inscricoes values (57004, 'G005', 11153, 2017, to_date('2017.09.10','YYYY.MM.DD'));
insert into inscricoes values (57004, 'G005', 11154, 2017, to_date('2017.09.10','YYYY.MM.DD'));
insert into inscricoes values (57004, 'G005', 7996, 2017, to_date('2017.09.10','YYYY.MM.DD'));

delete from inscricoes where cadeira = 7996;
insert into inscricoes values (57004, 'G005', 7336, 2017, to_date('2017.09.10','YYYY.MM.DD'));


-- Para a coisa ficar mesmo "à prova de bala", também há que fazer a verificação  quando se mudam os
-- créditos de uma cadeira,  e quando se muda uma inscricao.
-- Mas é tudo muito igual
create or replace trigger verifica_limite_credCadeira
  after update of ects on cadeiras
  declare NumECTS number;
  begin
    select max(total) into NumECTS from totalCred;
    if (NumECTS >  72)
      then Raise_Application_Error (-20100, 'Atingiu o limite de créditos. Inscrição não aceite!');
    end if;
  end;
/

create or replace trigger verifica_limite_muda_ins
  after update on inscricoes
  declare NumECTS number;
  begin
    select max(total) into NumECTS from totalCred;
    if (NumECTS >  72)
      then Raise_Application_Error (-20100, 'Atingiu o limite de créditos. Inscrição não aceite!');
    end if;
  end;
/

-- 4.1
alter table colocados drop constraint pk_col;
alter table matriculas drop constraint fk_matrcolcurso;
alter table colocados drop constraint un_col;
alter table colocados add constraint pk_col primary key (idCandidato, ano);

-- Nota: com isto o esquema deixa de estar normalizado!
-- Repare que idCandidato -> Nome
-- Antes isso não tinha problema pois idCandidato era chave. Mas agora deixa de ser!
-- Haveria que decompor a tabela de colocações em duas:
-- nomesColocados(idCandidato, Nome)
-- colocados(idCandidato, curso, ano).

-- Por agora, para simplificar o exercício, não vamos fazer isso, tendo apenas o cuidado de manter a consistência dos nomes
-- Fica como exercício extra fazer a coisa como deve ser. Ou seja, com a decomposição.

insert into colocados values (115680,'JOÃO M. A. F.','9209',2018);

-- 4.2

alter table matriculas add ano number(4,0);
update matriculas set ano = 2017;

alter table matriculas drop constraint un_mat;
alter table matriculas add constraint un_mat unique(idCandidato, ano);

alter table colocados add constraint un_col unique(idCandidato,curso,ano);
alter table matriculas add constraint fk_matrcolcurso foreign key (idCandidato,curso,ano) references colocados(idCandidato,curso,ano);

-- 4.3

create table inativas (
  numero number(6,0),
  curso varchar2(4)
  );

alter table inativas add constraint pk_ina primary key (numero, curso);
alter table inativas add constraint fk_ina foreign key (numero, curso) references matriculas(numero, curso);

-- 4.4
create or replace trigger muda_curso
  before insert on matriculas
  for each row
  declare Existe number;
  begin
    select count(*) into Existe
    from matriculas where idCandidato = :new.idcandidato;
    if Existe > 0
      then
        insert into inativas
          select numero, curso
          from matriculas
          where idCandidato = :new.idcandidato;
    end if;
  end;
/

-- 4.5
-- Tentemos então matricular o aluno 115680 em 2018, no curso de Matemática
insert into matriculas values (seq_num_aluno.nextval,115680,'9209',to_date('2018.09.10','YYYY.MM.DD'),2018);


-- 4.6
create or replace trigger impede_matr_ant
  before insert or update on inscricoes
  for each row
  declare Existe number;
  begin
    select count(*) into Existe
    from inativas
    where numero = :new.numero and curso = :new.curso;
    if Existe > 0
      then Raise_Application_Error (-20100, 'O aluno já não está nesse curso. Inscrição não aceite!');
    end if;
  end;
/

insert into inscricoes values (57006, '9209', 3107, 2018, to_date('2018.09.11','YYYY.MM.DD'));
