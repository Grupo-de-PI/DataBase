create database air_safe;

use air_safe;

-- ------------------------------------------clientes--------------------------------------------------------------------------------------

-- empresa que contratou nossos servicos
create table empresa (
	id_empresa int Primary key auto_increment,
    razao_social varchar(250) not null,
    nome_fantasia varchar (150) not null,
    cnpj char (14) unique not null,
    telefone varchar (14),
    fk_endereco int not null,
    constraint cfkEndEmp foreign key (fk_endereco) 
		references endereco(id_endereco)
);
insert into empresa (razao_social, nome_fantasia, cnpj, telefone_fixo, telefone_celular, fk_endereco) values
(	'Jaqueline e Valentina frigorífico Ltda',
	'FV Carnes',
    '12661774000142',
    '1926612748',
    '19992425550',
    1
);
select * from empresa;

-- funcionario dessa empresa que será o usuario
create table funcionario (
	id_funcionario int auto_increment,
    fk_empresa int,
    constraint pkFuncEmp primary key (id_funcionario, fk_empresa),
    constraint cfkEmp foreign key (fk_empresa) references empresa (id_empresa),
    nome varchar(15) not null,
    sobrenome varchar (90) not null,
    cargo varchar(100) not null,
    cpf char(11) unique not null,
    telefone varchar(14),
    email varchar (100) unique not null
);
insert into funcionario (fk_empresa, nome, sobrenome, cargo, dt_nasc, cpf, telefone_fixo, telefone_celular, email) values
 ( 1, 
  'Renato',
  'Carlos Eduardo Corte Real',
  'Coordenador de produção',
  '1997-01-18',
  '45944044489',
  '8127217471',
  '81991509348',
  'renato.carlos.cortereal@JaquelineValentina.frigorífico.com.br'
 ); 
 select * from funcionario;
 


-- ------------------------------------------extensões----------------------------------------------------------------------------------------
-- tabelas de relação forte, as quais servem de complemento a tabelas existentes; segurança e método contra redundãncia

-- login irá conter informações de acesso do funcionario
create table login (
	id_login int auto_increment,
    fk_func_id int,
    fk_func_emp int,
    constraint pkFuncEmp primary key (id_login, fk_func_emp, fk_func_id), -- Chaves primarias - tabela funcionario tem chaves compostas
    constraint cfkFuncEmp foreign key (fk_func_id, fk_func_emp) 
		references funcionario (id_funcionario, fk_empresa), -- foreign key composta
    email_login varchar(100) unique not null,
    senha varchar (20) not null,
    tipo_usuario varchar(14) not null,
	status_conta varchar(7) not null, 
    dt_cadastro datetime default current_timestamp,
    ultimo_login datetime default current_timestamp,

);
insert into login (fk_func_id, fk_func_emp, email_login, senha, tipo_usuario, status_conta, dt_cadastro, ultimo_login) values 
(	1, 
	1, 
    'renato.carlos.cortereal@JaquelineValentina.frigorífico.com.br', 
    'renato123', 
    'Controle Total',
    'ativo', 
    default,
    default)
;
    select * from login;

-- Complemento da tabela funcionario para evitar redundâncias e escalabilidade de processamento
create table endereco (
	id_endereco int primary key auto_increment,
    logradouro varchar(30) not null,
    numero int not null,
    bairro varchar(50) not null,
    cidade varchar (50) not null,
    estado_uf char(2) not null,
    cep char(8) not null,
    pais varchar(50) not null,
    complemento varchar (50)
);
insert into endereco (logradouro, numero, bairro, cidade, estado_uf, cep, pais, complemento ) values
(	'Rua Mirabela',
	435,
    'Chácara Belenzinho',
    'São Paulo', 
    'SP',
    '03376100', 
    'Brasil', 
    null
); 
select * from endereco;

-- ------------------------------------------sensores----------------------------------------------------------------------------------------- 
-- parte que diz respeitoa informações dos sensores

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
    cod_serie varchar (100) not null unique,
    tipo varchar(20) not null,
    dt_instalacao date not null,
    status_sensor varchar(7) not null,
    constraint cfkLocal foreign key (fk_local) 
		references local_monitoramento(id_local)
);
insert into sensor (fk_local, cod_serie, tipo, dt_instalacao, status_sensor) values 
(1, '93725789352', 'Mq-2', '2024-12-13', 'ativo');

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
-- insert de leitrua é por api 

show tables;

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
