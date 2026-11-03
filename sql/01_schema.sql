-- ==============================================================================
-- FACULDADE XX — SISTEMA DE ALOCAÇÃO DE ALUNOS E PROFESSORES
-- 01_SCHEMA.SQL — DEFINIÇÃO DE TABELAS E RESTRIÇÕES (DDL)
-- ==============================================================================

-- 1. DEPARTAMENTO
CREATE TABLE departamento (
    id_depto SERIAL PRIMARY KEY,
    sigla VARCHAR(10) NOT NULL UNIQUE,
    nome_depto VARCHAR(100) NOT NULL,
    id_chefe_prof INT NULL
);

-- 2. CURSO
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    codigo_curso VARCHAR(10) NOT NULL UNIQUE,
    nome_curso VARCHAR(100) NOT NULL,
    grau_academico VARCHAR(30) NOT NULL CHECK (grau_academico IN ('Bacharelado', 'Tecnólogo', 'Licenciatura')),
    duracao_semestres INT NOT NULL CHECK (duracao_semestres > 0),
    carga_horaria_total INT NOT NULL CHECK (carga_horaria_total > 0),
    id_depto INT NOT NULL REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 3. PROFESSOR
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

-- Adição de Chave Estrangeira de Chefia Departamental
ALTER TABLE departamento 
ADD CONSTRAINT fk_depto_chefe FOREIGN KEY (id_chefe_prof) 
REFERENCES professor(id_professor) ON UPDATE CASCADE ON DELETE SET NULL;

-- 4. DISCIPLINA
CREATE TABLE disciplina (
    id_disciplina SERIAL PRIMARY KEY,
    codigo_disciplina VARCHAR(15) NOT NULL UNIQUE,
    nome_disciplina VARCHAR(100) NOT NULL,
    carga_horaria INT NOT NULL CHECK (carga_horaria > 0),
    creditos INT NOT NULL CHECK (creditos > 0),
    ementa TEXT,
    id_depto INT NOT NULL REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- 5. MATRIZ_CURRICULAR (Relacionamento N:M entre Curso e Disciplina)
CREATE TABLE matriz_curricular (
    id_matriz SERIAL PRIMARY KEY,
    id_curso INT NOT NULL REFERENCES curso(id_curso) ON UPDATE CASCADE ON DELETE CASCADE,
    id_disciplina INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
    periodo_ideal INT NOT NULL CHECK (periodo_ideal > 0),
    obrigatoria BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_curso_disciplina UNIQUE (id_curso, id_disciplina)
);

-- 6. PRE_REQUISITO (Auto-relacionamento de Disciplina)
CREATE TABLE pre_requisito (
    id_disciplina INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE CASCADE,
    id_disciplina_prereq INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
    PRIMARY KEY (id_disciplina, id_disciplina_prereq),
    CONSTRAINT chk_nao_auto_prereq CHECK (id_disciplina <> id_disciplina_prereq)
);

-- 7. ALUNO
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

-- 8. TURMA (Núcleo da Alocação Docente e Espacial)
CREATE TABLE turma (
    id_turma SERIAL PRIMARY KEY,
    codigo_turma VARCHAR(25) NOT NULL UNIQUE,
    ano_semestre VARCHAR(10) NOT NULL,
    dia_semana VARCHAR(20) NOT NULL CHECK (dia_semana IN ('Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado')),
    horario_inicio TIME NOT NULL,
    horario_fim TIME NOT NULL,
    sala_bloco VARCHAR(40) NOT NULL,
    limite_vagas INT NOT NULL CHECK (limite_vagas > 0),
    id_disciplina INT NOT NULL REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
    id_professor INT NOT NULL REFERENCES professor(id_professor) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_horario_valido CHECK (horario_fim > horario_inicio)
);

-- 9. MATRICULA_TURMA (Núcleo da Alocação Discente e Histórico)
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
