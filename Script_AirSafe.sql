

use air_safe;


-- Complemento da tabela empresa para evitar redundâncias e escalabilidade de processamento
create table endereco (
	id_endereco int primary key auto_increment,
    logradouro varchar(30) not null,
    numero int not null,
    complemento varchar (50),
     bairro varchar(50) not null,
	cep char(8) not null,
    cidade varchar (50) not null,
    estado_uf char(2) not null,
    pais varchar(50) not null
);
insert into endereco (logradouro, numero, complemento,  bairro, cep, cidade, estado_uf, pais) values
	('Rua Mirabela',435, null, 'Chácara Belenzinho','03376100','São Paulo', 'SP ','Brasil' ); 

select * from endereco;




-- empresa que contratou nossos servicos
create table empresa (
	id_empresa int Primary key auto_increment,
    razao_social varchar(250) not null,
    nome_fantasia varchar (150) not null,
    cnpj char (14) unique not null,
    telefone_comecial varchar (14),
    telefone_celular varchar (14),
    codigo_ativacao varchar(20) not null,
    fk_endereco int not null,
    constraint cfkEndEmp foreign key (fk_endereco) 
		references endereco(id_endereco)
);
insert into empresa (razao_social, nome_fantasia, cnpj, telefone_comecial, telefone_celular, codigo_ativacao, fk_endereco) values
	('Jaqueline e Valentina frigorífico Ltda','FV Carnes','12661774000142','1926612748','19992425550','EF345',1);
select * from empresa;




-- funcionario dessa empresa que será o usuario
create table funcionario (
	id_funcionario int auto_increment,
    fk_empresa int,
    constraint pkFuncEmp primary key (id_funcionario, fk_empresa),
    nome varchar(15) not null,
    sobrenome varchar (90) not null,
    cpf char(11) unique not null,
    telefone varchar(14),
    email varchar (60) unique not null,
    senha varchar(20) not null,
	constraint cfkEmp foreign key (fk_empresa) 
		references empresa (id_empresa)
);
insert into funcionario (fk_empresa, nome, sobrenome, cpf, telefone, email, senha) values
 ( 1, 
  'Renato',
  'Carlos Eduardo Corte Real',
  '8127217471',
  '81991509348',
  'renato.carlos.cortereal@JaquelineValentina.com.br',
  '12345678'
 ); 
 select * from funcionario;




-- localização unica
create table local_monitoramento (
	id_local int primary key auto_increment,
    nome varchar(45) not null,
    descricao varchar(100) not null,
    setor varchar (45) not null,
    fk_empresa int,
    constraint cfkLocalEmpresa foreign key (fk_empresa) 
		references empresa(id_empresa)
);

insert into local_monitoramento (nome, descricao, setor, fk_empresa) values 
('Sala das máquinas', 'Sala que resfria a amônia por meio de condensadores e liberação externa', 'Norte', 1);
select * from local_monitoramento;



-- tabela sobre o sensor físico como produto
create table sensor (
	id_sensor int primary key auto_increment,
    fk_local int not null,
    cod_serie varchar (30) not null unique,
    dt_instalacao date not null,
    status_sensor tinyint not null,
    próxima_manutencao_preventiva date,
    ultima_manutencao_preditiva date,
    ultima_manutencao_corretiva date,
    constraint cfkLocal foreign key (fk_local) 
		references local_monitoramento(id_local)
);
insert into sensor (fk_local, cod_serie, dt_instalacao, status_sensor, próxima_manutencao_preventiva, ultima_manutencao_preditiva, ultima_manutencao_corretiva) values 
(1, '93725789359', '2024-12-13', 1, '2025-02-15', '2025-02-20', '2024-03-20'),
(1, '93725789310', '2024-12-13', 1, '2025-02-15', '2025-02-20', '2024-03-20');



-- tabela dependente da tabela sensor, onde armazenas os dados coletados no ambiente
create table leitura (
	id_leitura int auto_increment,
	fk_sensor int,
    constraint cpkLeituraSens primary key (id_leitura, fk_sensor),
    data_hora  datetime default current_timestamp,
    valor_ppm decimal (4,2) not null,
    constraint cfkSensor foreign key (fk_sensor)
		references sensor (id_sensor)
);


select * from leitura;

-- truncate table leitura; 

-- ---------------------------------------------------------------------------SELECTS-----------------------------------------------------------------------------------------------------------------------------	





-- Pack data manutenções -------------------------------------------------------------------------------------------------------------------------------------------------
create view vw_datas_manutencoes as
	select 
		próxima_manutencao_preventiva as Preventiva, 
		ultima_manutencao_preditiva as Preditiva, 
		ultima_manutencao_corretiva as Corretiva
	from sensor;
    
select * from vw_datas_manutencoes;
-- ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------









-- Pack de histórico geral e por sensor --------------------------------------------------------------------------------------------------------------------------------------------------------

create view vw_historico_registros as
	select 
		emp.codigo_ativacao as codigo,
		loc.fk_empresa as id_emp,
		sens.fk_local as id_loc,
		lei.fk_sensor as id_sens,
		TIME(data_hora) as HoraRegistro,
		lei.valor_ppm as valor
	from 
		empresa as emp join local_monitoramento as loc	
			on emp.id_empresa = loc.fk_empresa
		join sensor as sens
			on loc.id_local = sens.fk_local
		join leitura as lei
			on lei.fk_sensor = sens.id_sensor;

-- Registros gerais
select * from vw_historico_registros;

-- Registro por sensor
select HoraRegistro, valor from vw_historico_registros 
	where fk_sensor = 1;

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------








-- Pack de distribuição de vazamentos % ---------------------------------------------------------------------------------------------------------------------------------------------------------------

 create view vw_distribuicao as
	select 
		emp.codigo_ativacao as codigo,
		loc.fk_empresa as id_emp,
        loc.nome as nome_loc,
		lei.fk_sensor as id_sens,
        month(data_hora) as mesRegistro,
		TIME(data_hora) as horaRegistro,
		lei.valor_ppm as valor
	from 
		empresa as emp join local_monitoramento as loc	
			on emp.id_empresa = loc.fk_empresa
		join sensor as sens
			on loc.id_local = sens.fk_local
		join leitura as lei
			on lei.fk_sensor = sens.id_sensor;
   
   -- geral
	select * from vw_distribuicao;
    
    -- Por local
	select nome_loc, count(valor) 
		from vw_distribuicao
		where valor > 10
        group by nome_loc;
  
  -- Pack de registros medios -------
       select nome_loc, avg(valor) 
		from vw_distribuicao
        group by nome_loc;


-- Pack dias sem vazamento --------
    -- Por local
	select mesRegistro
		from vw_distribuicao
        where valor > 10;
        
        
-- Pack dias sensores ativos ----------
    -- Sensores ativos
	select count(id_sensor) from sensor
		where status_sensor = 1;
        
        
	-- Sensores totais
        -- Sensores ativos
	select count(id_sensor) from sensor; 6