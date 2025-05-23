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
    fkEmpresa int,
    constraint cfkLocalEmpresa foreign key (fkempresa) 
		references empresa(id_empresa)
);
insert into local_monitoramento (nome, descricao, setor, fkEmpresa) values 
('Sala das máquinas', 'Sala que resfria a amônia por meio de condensadores e liberação externa', 'Norte', 1);
select * from local_monitoramento;




-- tabela sobre o sensor físico como produto
create table sensor (
	id_sensor int primary key auto_increment,
    fk_local int unique not null,
    cod_serie varchar (30) not null unique,
    dt_instalacao date not null,
    status_sensor tinyint not null,
    ultima_manutencao_preventiva date,
    ultima_manutencao_preditiva date,
    ultima_manutencao_corretiva date,
    constraint cfkLocal foreign key (fk_local) 
		references local_monitoramento(id_local)
);
insert into sensor (fk_local, cod_serie, dt_instalacao, status_sensor, ultima_manutencao_preventiva, ultima_manutencao_preditiva, ultima_manutencao_corretiva) values 
	(1, '93725789352', '2024-12-13', 1, null, null, null);




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

insert into leitura values 
(2,1,default,10.00);

select * from leitura;

-- ---------------------------------------------------------------------------SELECTS-----------------------------------------------------------------------------------------------------------------------------	

-- select empresa x endereco
select 
-- empresa
emp.razao_social as 'Razão social da Empresa', 
emp.nome_fantasia as 'Nome Fantasia da empresa', 
emp.cnpj as 'CNPJ', 
emp.telefone_fixo as 'Telefone Fixo', 
emp.telefone_celular as 'Celular para contato', 
-- endereço
concat(
	ende.logradouro, ', nº ',
	ende.numero, ', ',
	ifnull(ende.complemento, 'Sem complemento'), ', ',
	ende.bairro, ', ',
	ende.cidade, '/',
	ende.estado_uf, ' - ',
	ende.cep, ' - ',
	ende.pais
) as 'Endereço'
from 
empresa as emp join endereco as ende 
	on emp.fk_endereco = ende.id_endereco;
    
    
-- locais x Sensores x monitoramento
select 
	-- localização
	loc.nome as 'Local' , 
	loc.descricao as 'Descrição do local', 
	loc.setor as 'Zona do local', 
	-- sensores
	sens.cod_serie as 'codigo de serie', 
	sens.tipo as 'Modelo do sensor', 
	sens.dt_instalacao as 'Data de instalação', 
	sens.status_sensor as 'Status do sensor',
	-- Valores coletados
	val.data_hora as 'Momento da captura', 
	val.valor_ppm as 'Nível de amônia' 
from local_monitoramento as loc join sensor as sens
	on sens.fk_local = loc.id_local
left join leitura as val
	on val.fk_sensor = sens.id_sensor;
    
    



-- locais x sensores x monitoramento - maiores que 10
select 
	-- localização
	loc.nome as 'Local' , 
	loc.descricao as 'Descrição do local', 
	loc.setor as 'Zona do local', 
	-- sensores
	sens.cod_serie as 'codigo de serie', 
	sens.tipo as 'Modelo do sensor', 
	sens.dt_instalacao as 'Data de instalação', 
	sens.status_sensor as 'Status do sensor',
	-- Valores coletados
	val.data_hora as 'Momento da captura', 
	val.valor_ppm as 'Nível de amônia' 
from local_monitoramento as loc join sensor as sens
	on sens.fk_local = loc.id_local
left join leitura as val
	on val.fk_sensor = sens.id_sensor
    where val.valor_ppm > 10;
