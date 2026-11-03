-- ==============================================================================
-- FACULDADE XX — SISTEMA DE ALOCAÇÃO DE ALUNOS E PROFESSORES
-- 02_SEED_DATA.SQL — CARGA DE DADOS REALISTAS DE TESTE (DML)
-- ==============================================================================

-- Departamentos
INSERT INTO departamento (sigla, nome_depto) VALUES
('DCOMP', 'Departamento de Computação e Tecnologia'),
('DMED',  'Departamento de Ciências Médicas e Saúde'),
('DAERO', 'Departamento de Engenharia Aeroespacial'),
('DFISIO','Departamento de Fisioterapia e Reabilitação'),
('DADM',  'Departamento de Gestão e Recursos Humanos');

-- Os 5 Cursos da Faculdade XX
INSERT INTO curso (codigo_curso, nome_curso, grau_academico, duracao_semestres, carga_horaria_total, id_depto) VALUES
('SI',    'Sistemas de Informação',      'Bacharelado', 8,  3200, 1),
('MED',   'Medicina',                    'Bacharelado', 12, 7200, 2),
('AERO',  'Engenharia Aeroespacial',     'Bacharelado', 10, 4200, 3),
('FISIO', 'Fisioterapia',                'Bacharelado', 10, 4000, 4),
('RH',    'Gestão de Recursos Humanos',   'Tecnólogo',   4,  1800, 5);

-- Professores
INSERT INTO professor (matricula_prof, nome_completo, cpf, email_institucional, telefone, titulacao, regime_trabalho, data_admissao, id_depto) VALUES
('PRF201801', 'Dr. Carlos Alberto Mendes',   '111.222.333-01', 'carlos.mendes@faculdadexx.edu.br',   '(21) 98765-1001', 'Doutor',      'Dedicação Exclusiva', '2018-02-01', 1),
('PRF201902', 'Dra. Mariana Silva Ramos',     '222.333.444-02', 'mariana.ramos@faculdadexx.edu.br',   '(21) 98765-1002', 'Doutor',      'Dedicação Exclusiva', '2019-03-15', 2),
('PRF202003', 'Dr. Roberto Santos Ferreira', '333.444.555-03', 'roberto.santos@faculdadexx.edu.br',  '(21) 98765-1003', 'Doutor',      'Dedicação Exclusiva', '2020-08-01', 3),
('PRF202104', 'Msc. Juliana Costa Lima',     '444.555.666-04', 'juliana.lima@faculdadexx.edu.br',    '(21) 98765-1004', 'Mestre',      '40h',                 '2021-02-10', 4),
('PRF202205', 'Msc. Fernando Alves Pires',   '555.666.777-05', 'fernando.pires@faculdadexx.edu.br',  '(21) 98765-1005', 'Mestre',      '20h',                 '2022-04-01', 5);

-- Vinculação de Chefia
UPDATE departamento SET id_chefe_prof = 1 WHERE id_depto = 1;
UPDATE departamento SET id_chefe_prof = 2 WHERE id_depto = 2;
UPDATE departamento SET id_chefe_prof = 3 WHERE id_depto = 3;
UPDATE departamento SET id_chefe_prof = 4 WHERE id_depto = 4;
UPDATE departamento SET id_chefe_prof = 5 WHERE id_depto = 5;

-- Disciplinas dos Cursos
INSERT INTO disciplina (codigo_disciplina, nome_disciplina, carga_horaria, creditos, ementa, id_depto) VALUES
('SI101',   'Banco de Dados I',             80, 4, 'Modelagem conceitual, lógica e física. Normalização. SQL.', 1),
('SI102',   'Algoritmos e Programação',     80, 4, 'Lógica computacional, estruturas condicionais e repetição.', 1),
('MED201',  'Anatomia Humana I',            120, 6, 'Estudo morfológico dos sistemas do corpo humano.', 2),
('AERO301', 'Aerodinâmica Aplicada',       100, 5, 'Equações de escoamento, sustentação e arrasto em aeronaves.', 3),
('FISIO401','Cinesiologia e Biomecânica',   80, 4, 'Análise biomecânica do movimento humano e postura.', 4),
('RH501',   'Gestão de Pessoas e Carreira', 60, 3, 'Processos de atração, retenção, planos de cargos e salários.', 5);

-- Matriz Curricular
INSERT INTO matriz_curricular (id_curso, id_disciplina, periodo_ideal, obrigatoria) VALUES
(1, 1, 3, TRUE),
(1, 2, 1, TRUE),
(2, 3, 1, TRUE),
(3, 4, 5, TRUE),
(4, 5, 2, TRUE),
(5, 6, 1, TRUE);

-- Alunos
INSERT INTO aluno (matricula_aluno, nome_completo, cpf, data_nascimento, email, telefone, endereco, data_ingresso, id_curso) VALUES
('202410101', 'Lucas Bezerra de Oliveira',  '010.203.405-11', '2001-05-12', 'lucas.oliveira@aluno.faculdadexx.edu.br',  '(21) 97111-2233', 'Av. Rio Branco, 1000 - Centro, Rio de Janeiro - RJ', '2024-02-01', 1),
('202410102', 'Beatriz Souza Martins',      '020.304.506-22', '2002-08-20', 'beatriz.martins@aluno.faculdadexx.edu.br', '(21) 97222-3344', 'Rua Visconde de Pirajá, 450 - Ipanema, Rio de Janeiro - RJ',   '2024-02-01', 2),
('202410103', 'Gabriel Santos Nogueira',    '030.405.607-33', '2000-11-03', 'gabriel.santos@aluno.faculdadexx.edu.br',  '(21) 97333-4455', 'Praia de Botafogo, 800 - Botafogo, Rio de Janeiro - RJ', '2024-02-01', 3),
('202410104', 'Camila Rodrigues Lima',      '040.506.708-44', '2003-03-15', 'camila.lima@aluno.faculdadexx.edu.br',     '(21) 97444-5566', 'Av. Atlântica, 120 - Copacabana, Rio de Janeiro - RJ', '2024-02-01', 4),
('202410105', 'Rodrigo Mendes Barreto',     '050.607.809-55', '1999-07-28', 'rodrigo.mendes@aluno.faculdadexx.edu.br',  '(21) 97555-6677', 'Av. das Américas, 900 - Barra da Tijuca, Rio de Janeiro - RJ', '2024-02-01', 5);

-- Turmas Ofertadas (Alocação Docente e Espacial)
INSERT INTO turma (codigo_turma, ano_semestre, dia_semana, horario_inicio, horario_fim, sala_bloco, limite_vagas, id_disciplina, id_professor) VALUES
('TURMA-SI-BD-2026.1',     '2026.1', 'Segunda-feira', '19:00', '22:30', 'Laboratório de Informática 3 - Bloco B', 40, 1, 1),
('TURMA-MED-ANAT-2026.1',  '2026.1', 'Terça-feira',   '08:00', '12:00', 'Laboratório Anatômico 1 - Bloco Saúde',    30, 3, 2),
('TURMA-AERO-AERO-2026.1', '2026.1', 'Quarta-feira',  '14:00', '18:00', 'Sala de Projetos Aero 2 - Bloco Eng',      35, 4, 3),
('TURMA-FISIO-CIN-2026.1', '2026.1', 'Quinta-feira',  '13:30', '17:00', 'Clínica Escola Fisioterapia - Bloco D',    30, 5, 4),
('TURMA-RH-GP-2026.1',     '2026.1', 'Sexta-feira',   '19:00', '22:00', 'Sala de Aula 204 - Bloco Central',         50, 6, 5);

-- Inscrições em Turma (Alocação Discente e Histórico)
INSERT INTO matricula_turma (id_aluno, id_turma, data_inscricao, nota_1, nota_2, nota_final, frequencia_pct, situacao) VALUES
(1, 1, '2026-02-10', 9.5, 9.0, 9.25, 96.0, 'Cursando'),
(2, 2, '2026-02-11', 8.5, 9.0, 8.75, 98.0, 'Cursando'),
(3, 3, '2026-02-10', 9.0, 8.0, 8.50, 92.0, 'Cursando'),
(4, 4, '2026-02-12', 8.0, 8.5, 8.25, 94.0, 'Cursando'),
(5, 5, '2026-02-10', 10.0, 9.5, 9.75, 100.0, 'Cursando');
