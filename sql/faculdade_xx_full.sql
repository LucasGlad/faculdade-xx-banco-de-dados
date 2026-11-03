-- ==============================================================================
-- FACULDADE XX — SISTEMA DE ALOCAÇÃO DE ALUNOS E PROFESSORES
-- SCRIPT DDL E DML DO BANCO DE DADOS RELACIONAL (POSTGRESQL / MYSQL COMPATÍVEL)
-- ==============================================================================

-- 1. CRIAÇÃO DAS TABELAS (DDL)
-- ------------------------------------------------------------------------------

-- Tabela: DEPARTAMENTO
CREATE TABLE departamento (
    id_depto SERIAL PRIMARY KEY,
    sigla VARCHAR(10) NOT NULL UNIQUE,
    nome_depto VARCHAR(100) NOT NULL,
    id_chefe_prof INT NULL
);

-- Tabela: CURSO
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    codigo_curso VARCHAR(10) NOT NULL UNIQUE,
    nome_curso VARCHAR(100) NOT NULL,
    grau_academico VARCHAR(30) NOT NULL CHECK (grau_academico IN ('Bacharelado', 'Tecnólogo', 'Licenciatura')),
    duracao_semestres INT NOT NULL CHECK (duracao_semestres > 0),
    carga_horaria_total INT NOT NULL CHECK (carga_horaria_total > 0),
    id_depto INT NOT NULL REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Tabela: PROFESSOR
CREATE TABLE professor (
    id_professor SERIAL PRIMARY KEY,
    matricula_prof VARCHAR(15) NOT NULL UNIQUE,
    nome_completo VARCHAR(120) NOT NULL,
    cpf CHAR(14) NOT NULL UNIQUE,
    email_institucional VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    titulacao VARCHAR(30) NOT NULL CHECK (titulacao IN ('Especialista', 'Mestre', 'Doutor', 'Pós-Doutor')),
    regime_trabalho VARCHAR(20) NOT NULL CHECK (regime_trabalho IN ('20h', '40h', 'Dedicação Exclusiva')),
    data_admissao DATE NOT NULL,
    id_depto INT NOT NULL REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Adicionar FK de chefia do departamento
ALTER TABLE departamento 
ADD CONSTRAINT fk_depto_chefe FOREIGN KEY (id_chefe_prof) 
REFERENCES professor(id_professor) ON UPDATE CASCADE ON DELETE SET NULL;

-- Tabela: DISCIPLINA
CREATE TABLE disciplina (
    id_disciplina SERIAL PRIMARY KEY,
    codigo_disciplina VARCHAR(15) NOT NULL UNIQUE,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria INT NOT NULL CHECK (carga_horaria > 0),
    creditos INT NOT NULL CHECK (creditos > 0),
    ementa TEXT,
    id_depto INT NOT NULL REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Tabela: MATRIZ_CURRICULAR (Relacionamento N:M entre Curso e Disciplina)
CREATE TABLE matriz_curricular (
    id_matriz SERIAL PRIMARY KEY,
    id_curso INT NOT NULL REFERENCES curso(id_curso) ON UPDATE CASCADE ON DELETE CASCADE,
    id_disciplina INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
    periodo_ideal INT NOT NULL CHECK (periodo_ideal > 0),
    obrigatoria BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_curso_disciplina UNIQUE (id_curso, id_disciplina)
);

-- Tabela: PRE_REQUISITO (Auto-relacionamento de Disciplina)
CREATE TABLE pre_requisito (
    id_disciplina INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE CASCADE,
    id_disciplina_prereq INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (id_disciplina, id_disciplina_prereq),
    CONSTRAINT chk_nao_auto_prereq CHECK (id_disciplina <> id_disciplina_prereq)
);

-- Tabela: ALUNO
CREATE TABLE aluno (
    id_aluno SERIAL PRIMARY KEY,
    matricula_aluno VARCHAR(15) NOT NULL UNIQUE,
    nome_completo VARCHAR(120) NOT NULL,
    cpf CHAR(14) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    endereco VARCHAR(200),
    data_ingresso DATE NOT NULL,
    status_matricula VARCHAR(20) NOT NULL DEFAULT 'Ativo' 
        CHECK (status_matricula IN ('Ativo', 'Trancado', 'Formado', 'Desistente')),
    id_curso INT NOT NULL REFERENCES curso(id_curso) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Tabela: TURMA (Núcleo da Alocação Docente e de Espaço/Horário)
CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    codigo_turma VARCHAR(25) NOT NULL UNIQUE,
    ano_semestre VARCHAR(10) NOT NULL, -- Ex: '2026.1'
    dia_semana VARCHAR(20) NOT NULL CHECK (dia_semana IN ('Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado')),
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    sala_bloco VARCHAR(40) NOT NULL,
    limite_vagas INT NOT NULL CHECK (limite_vagas > 0),
    id_disciplina INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_professor INT NOT NULL REFERENCES professor(id_professor) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_horario_valido CHECK (horario_fim > horario_inicio)
);

-- Tabela: MATRICULA_TURMA (Núcleo da Alocação de Alunos nas Turmas Ofertadas)
CREATE TABLE matricula_turma (
    id_matricula_turma SERIAL PRIMARY KEY,
    id_aluno INT NOT NULL REFERENCES aluno(id_aluno) ON UPDATE CASCADE ON DELETE CASCADE,
    id_turma INT NOT NULL REFERENCES turma(id_turma) ON UPDATE CASCADE ON DELETE RESTRICT,
    data_inscricao DATE NOT NULL DEFAULT CURRENT_DATE,
    nota_1 DECIMAL(4,2) CHECK (nota_1 >= 0 AND nota_1 <= 10),
    nota_2 DECIMAL(4,2) CHECK (nota_2 >= 0 AND nota_2 <= 10),
    nota_final DECIMAL(4,2) CHECK (nota_final >= 0 AND nota_final <= 10),
    frequencia_pct DECIMAL(5,2) CHECK (frequencia_pct >= 0 AND frequencia_pct <= 100),
    situacao VARCHAR(25) NOT NULL DEFAULT 'Cursando' 
        CHECK (situacao IN ('Cursando', 'Aprovado', 'Reprovado por Nota', 'Reprovado por Falta', 'Trancado')),
    CONSTRAINT uq_aluno_turma UNIQUE (id_aluno, id_turma)
);

-- ------------------------------------------------------------------------------
-- 2. CARGA DE DADOS DE EXEMPLO (DML) - FACULDADE XX
-- ------------------------------------------------------------------------------

-- Inserindo Departamentos
INSERT INTO departamento (sigla, nome_depto) VALUES
('DCOMP', 'Departamento de Computação e Tecnologia'),
('DMED',  'Departamento de Ciências Médicas e Saúde'),
('DAERO', 'Departamento de Engenharia Aeroespacial'),
('DFISIO','Departamento de Fisioterapia e Reabilitação'),
('DADM',  'Departamento de Gestão e Recursos Humanos');

-- Inserindo Cursos (Os 5 cursos obrigatórios do enunciado)
INSERT INTO curso (codigo_curso, nome_curso, grau_academico, duracao_semestres, carga_horaria_total, id_depto) VALUES
('SI',    'Sistemas de Informação',      'Bacharelado', 8,  3200, 1),
('MED',   'Medicina',                    'Bacharelado', 12, 7200, 2),
('AERO',  'Engenharia Aeroespacial',     'Bacharelado', 10, 4200, 3),
('FISIO', 'Fisioterapia',                'Bacharelado', 10, 4000, 4),
('RH',    'Gestão de Recursos Humanos',   'Tecnólogo',   4,  1800, 5);

-- Inserindo Professores (Amostra dos ~200 professores da Faculdade XX)
INSERT INTO professor (matricula_prof, nome_completo, cpf, email_institucional, telefone, titulacao, regime_trabalho, data_admissao, id_depto) VALUES
('PRF201801', 'Dr. Carlos Alberto Mendes',   '111.222.333-01', 'carlos.mendes@faculdadexx.edu.br',   '(21) 98765-1001', 'Doutor',      'Dedicação Exclusiva', '2018-02-01', 1),
('PRF201902', 'Dra. Mariana Silva Ramos',     '222.333.444-02', 'mariana.ramos@faculdadexx.edu.br',   '(21) 98765-1002', 'Doutor',      'Dedicação Exclusiva', '2019-03-15', 2),
('PRF202003', 'Dr. Roberto Santos Ferreira', '333.444.555-03', 'roberto.santos@faculdadexx.edu.br',  '(21) 98765-1003', 'Doutor',      'Dedicação Exclusiva', '2020-08-01', 3),
('PRF202104', 'Msc. Juliana Costa Lima',     '444.555.666-04', 'juliana.lima@faculdadexx.edu.br',    '(21) 98765-1004', 'Mestre',      '40h',                 '2021-02-10', 4),
('PRF202205', 'Msc. Fernando Alves Pires',   '555.666.777-05', 'fernando.pires@faculdadexx.edu.br',  '(21) 98765-1005', 'Mestre',      '20h',                 '2022-04-01', 5);

-- Atualizando Chefes de Departamento
UPDATE departamento SET id_chefe_prof = 1 WHERE id_depto = 1;
UPDATE departamento SET id_chefe_prof = 2 WHERE id_depto = 2;
UPDATE departamento SET id_chefe_prof = 3 WHERE id_depto = 3;
UPDATE departamento SET id_chefe_prof = 4 WHERE id_depto = 4;
UPDATE departamento SET id_chefe_prof = 5 WHERE id_depto = 5;

-- Inserindo Disciplinas
INSERT INTO disciplina (codigo_disciplina, nome_disciplina, carga_horaria, creditos, ementa, id_depto) VALUES
('SI101',   'Banco de Dados I',             80, 4, 'Modelagem conceitual, lógica e física. Normalização. SQL.', 1),
('SI102',   'Algoritmos e Programação',     80, 4, 'Lógica computacional, estruturas condicionais e repetição.', 1),
('MED201',  'Anatomia Humana I',            120, 6, 'Estudo morfológico dos sistemas do corpo humano.', 2),
('AERO301', 'Aerodinâmica Aplicada',       100, 5, 'Equações de escoamento, sustentação e arrasto em aeronaves.', 3),
('FISIO401','Cinesiologia e Biomecânica',   80, 4, 'Análise biomecânica do movimento humano e postura.', 4),
('RH501',   'Gestão de Pessoas e Carreira', 60, 3, 'Processos de atração, retenção, planos de cargos e salários.', 5);

-- Inserindo Matriz Curricular dos Cursos
INSERT INTO matriz_curricular (id_curso, id_disciplina, periodo_ideal, obrigatoria) VALUES
(1, 1, 3, TRUE), -- SI: Banco de Dados I no 3º semestre
(1, 2, 1, TRUE), -- SI: Algoritmos no 1º semestre
(2, 3, 1, TRUE), -- Medicina: Anatomia Humana no 1º semestre
(3, 4, 5, TRUE), -- Eng. Aeroespacial: Aerodinâmica no 5º semestre
(4, 5, 2, TRUE), -- Fisioterapia: Cinesiologia no 2º semestre
(5, 6, 1, TRUE); -- Gestão RH: Gestão de Pessoas no 1º semestre

-- Inserindo Alunos (Amostra dos ~4.000 alunos)
INSERT INTO aluno (matricula_aluno, nome_completo, cpf, data_nascimento, email, telefone, endereco, data_ingresso, id_curso) VALUES
('202410101', 'Lucas Bezerra de Oliveira',  '010.203.405-11', '2001-05-12', 'lucas.oliveira@aluno.faculdadexx.edu.br',  '(21) 97111-2233', 'Av. Rio Branco, 1000 - Centro, Rio de Janeiro - RJ', '2024-02-01', 1),
('202410102', 'Beatriz Souza Martins',      '020.304.506-22', '2002-08-20', 'beatriz.martins@aluno.faculdadexx.edu.br', '(21) 97222-3344', 'Rua Visconde de Pirajá, 450 - Ipanema, Rio de Janeiro - RJ',   '2024-02-01', 2),
('202410103', 'Gabriel Santos Nogueira',    '030.405.607-33', '2000-11-03', 'gabriel.santos@aluno.faculdadexx.edu.br',  '(21) 97333-4455', 'Praia de Botafogo, 800 - Botafogo, Rio de Janeiro - RJ', '2024-02-01', 3),
('202410104', 'Camila Rodrigues Lima',      '040.506.708-44', '2003-03-15', 'camila.lima@aluno.faculdadexx.edu.br',     '(21) 97444-5566', 'Av. Atlântica, 120 - Copacabana, Rio de Janeiro - RJ', '2024-02-01', 4),
('202410105', 'Rodrigo Mendes Barreto',     '050.607.809-55', '1999-07-28', 'rodrigo.mendes@aluno.faculdadexx.edu.br',  '(21) 97555-6677', 'Av. das Américas, 900 - Barra da Tijuca, Rio de Janeiro - RJ', '2024-02-01', 5);

-- Inserindo Turmas Ofertadas (ALOCAÇÃO DE PROFESSORES PARA DISCIPLINAS)
INSERT INTO turma (codigo_turma, ano_semestre, dia_semana, horario_inicio, horario_fim, sala_bloco, limite_vagas, id_disciplina, id_professor) VALUES
('TURMA-SI-BD-2026.1',     '2026.1', 'Segunda-feira', '19:00', '22:30', 'Laboratório de Informática 3 - Bloco B', 40, 1, 1),
('TURMA-MED-ANAT-2026.1',  '2026.1', 'Terça-feira',   '08:00', '12:00', 'Laboratório Anatômico 1 - Bloco Saúde',    30, 3, 2),
('TURMA-AERO-AERO-2026.1', '2026.1', 'Quarta-feira',  '14:00', '18:00', 'Sala de Projetos Aero 2 - Bloco Eng',      35, 4, 3),
('TURMA-FISIO-CIN-2026.1', '2026.1', 'Quinta-feira',  '13:30', '17:00', 'Clínica Escola Fisioterapia - Bloco D',    30, 5, 4),
('TURMA-RH-GP-2026.1',     '2026.1', 'Sexta-feira',   '19:00', '22:00', 'Sala de Aula 204 - Bloco Central',         50, 6, 5);

-- Inserindo Matrículas em Turma (ALOCAÇÃO DE ALUNOS NAS TURMAS)
INSERT INTO matricula_turma (id_aluno, id_turma, data_inscricao, nota_1, nota_2, nota_final, frequencia_pct, situacao) VALUES
(1, 1, '2026-02-10', 9.5, 9.0, 9.25, 96.0, 'Cursando'),
(2, 2, '2026-02-11', 8.5, 9.0, 8.75, 98.0, 'Cursando'),
(3, 3, '2026-02-10', 9.0, 8.0, 8.50, 92.0, 'Cursando'),
(4, 4, '2026-02-12', 8.0, 8.5, 8.25, 94.0, 'Cursando'),
(5, 5, '2026-02-10', 10.0, 9.5, 9.75, 100.0, 'Cursando');

-- ------------------------------------------------------------------------------
-- 3. CONSULTAS SQL DE NEGÓCIO PARA VERIFICAÇÃO DAS ALOCAÇÕES
-- ------------------------------------------------------------------------------

-- Consulta 1: Relatório de Alocação de Docentes (Quais professores estão lecionando quais turmas e disciplinas)
SELECT 
    p.matricula_prof,
    p.nome_completo AS professor,
    p.titulacao,
    d.codigo_disciplina,
    d.nome_disciplina,
    t.codigo_turma,
    t.ano_semestre,
    t.dia_semana,
    t.horario_inicio,
    t.horario_fim,
    t.sala_bloco,
    t.limite_vagas
FROM turma t
INNER JOIN professor p ON t.id_professor = p.id_professor
INNER JOIN disciplina d ON t.id_disciplina = d.id_disciplina
ORDER BY t.ano_semestre, p.nome_completo;

-- Consulta 2: Relatório de Alocação de Discentes (Comprovante de Matrícula do Aluno em Turmas)
SELECT 
    a.matricula_aluno,
    a.nome_completo AS aluno,
    c.nome_curso,
    t.codigo_turma,
    d.nome_disciplina,
    p.nome_completo AS professor_responsavel,
    t.dia_semana,
    t.horario_inicio,
    t.sala_bloco,
    mt.situacao
FROM matricula_turma mt
INNER JOIN aluno a ON mt.id_aluno = a.id_aluno
INNER JOIN curso c ON a.id_curso = c.id_curso
INNER JOIN turma t ON mt.id_turma = t.id_turma
INNER JOIN disciplina d ON t.id_disciplina = d.id_disciplina
INNER JOIN professor p ON t.id_professor = p.id_professor
ORDER BY a.nome_completo, t.dia_semana;
