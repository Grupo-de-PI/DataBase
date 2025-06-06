create database air_safe;

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
	('Rua Mirabela',435, null, 'Chácara Belenzinho','03376100','São Paulo', 'SP ','Brasil' ),
	('Rua Frigos',345, null, 'Chácara Frigos','03376500','São Paulo', 'SP ','Brasil' );

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
	('AirSafe Ltda.', 'AirSafe', '12261171000147', '1926612749', '19992425551', 'AS345',1),
    ('Jaqueline e Valentina frigorífico Ltda','FV Carnes','12661774000142','1926612748','19992425550','EF345',2);

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
 ( 2, 
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
('Sala das maquinas', 'Sala que resfria a amônia por meio de condensadores e liberação externa', 'Norte', 2),
('Câmara de Refriamento', 'Sala que resfria a amônia por meio de condensadores e liberação externa', 'Norte', 2),
('Câmara de estocggem', 'Sala que resfria a amônia por meio de condensadores e liberação externa', 'Norte', 2),
('Túnel congelador', 'Sala que resfria a amônia por meio de condensadores e liberação externa', 'Norte', 2);

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

insert into sensor (fk_local, cod_serie, dt_instalacao, status_sensor, próxima_manutencao_preventiva, ultima_manutencao_preditiva, ultima_manutencao_corretiva) values 
(2, '23725789359', '2024-12-13', 1, '2025-02-15', '2025-02-20', '2024-03-20'),
(3, '33725789310', '2024-12-13', 1, '2025-02-15', '2025-02-20', '2024-03-20'),
(4, '43725789310', '2024-12-13', 1, '2025-02-15', '2025-02-20', '2024-03-20');

select * from sensor;



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
 insert into leitura (fk_sensor, valor_ppm) values
	(1,18.00),
	(2,17.00),
	(3,16.00),
	(4,15.00),
	(5,23.00),
	(5,30.00),
	(3,90.00);
    
    


select * from leitura;

-- truncate table leitura; 

-- ---------------------------------------------------------------------------SELECTS-----------------------------------------------------------------------------------------------------------------------------	




-- Pack de histórico geral e por sensor --------------------------------------------------------------------------------------------------------------------------------------------------------

-- Com intuito o grafico de linha
create view vw_historico_registros as
	select 
		emp.id_empresa as id_emp,
        emp.codigo_ativacao as codigo,
        loc.id_local as id_loc, 
        loc.nome as nome_loc,
        sens.id_sensor as id_sens,
        sens.status_sensor as status_sens,
		data_hora as HoraRegistro,
		lei.valor_ppm as valor
	from 
		empresa as emp join local_monitoramento as loc	
			on emp.id_empresa = loc.fk_empresa
		right join sensor as sens
			on loc.id_local = sens.fk_local
		join leitura as lei
			on lei.fk_sensor = sens.id_sensor;
            
select * from vw_historico_registros ;


-- Grafico de linha 
select distinct nome_loc, avg(valor), DATE_FORMAT(time(HoraRegistro), '%H:%i:%s') AS HoraRegistro from vw_historico_registros 
	where codigo = 'EF345' 
		group by nome_loc, DATE_FORMAT(time(HoraRegistro), '%H:%i:%s');

-- Gráfico de barra
select distinct nome_loc,  avg(valor) as media from vw_historico_registros where codigo = 'EF345' group by id_loc;

-- Gráfico de Porcentage,
select * from leitura;

truncate table leitura;

-- KPIS
-- KPI 1 - dias sem vazamento
SELECT 
  DATEDIFF(CURDATE(), MAX(DATE(HoraRegistro))) AS dias
FROM vw_historico_registros
WHERE valor > 17 	;

-- KPI 2 - sensores
	select 
		(select count(id_sensor) from sensor) as sensores_totais,
		(select count(status_sensor) from sensor where status_sensor=1) as sensores_ativos
		from vw_historico_registros 
        where codigo = 'EF345'
        group by sensores_totais, sensores_ativos;

-- KPI 3 - Maior media
	select distinct nome_loc from vw_historico_registros 
		where CURDATE() and valor = (select max(valor) from vw_historico_registros);



