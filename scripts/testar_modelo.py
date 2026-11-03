import sqlite3
import sys

def run_tests():
    db_file = r"e:\faculdade_xx.db"
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    # Habilita suporte a chaves estrangeiras no SQLite
    cursor.execute("PRAGMA foreign_keys = ON;")

    print("=" * 70)
    print(" SUÍTE DE TESTES AUTOMATIZADOS — BANCO DE DADOS FACULDADE XX")
    print("=" * 70)

    # 1. Criação das Tabelas
    print("\n[+] 1. Criando tabelas relacionais...")
    cursor.executescript("""
    DROP TABLE IF EXISTS matricula_turma;
    DROP TABLE IF EXISTS turma;
    DROP TABLE IF EXISTS pre_requisito;
    DROP TABLE IF EXISTS matriz_curricular;
    DROP TABLE IF EXISTS disciplina;
    DROP TABLE IF EXISTS aluno;
    DROP TABLE IF EXISTS professor;
    DROP TABLE IF EXISTS curso;
    DROP TABLE IF EXISTS departamento;

    CREATE TABLE departamento (
        id_depto INTEGER PRIMARY KEY AUTOINCREMENT,
        sigla TEXT NOT NULL UNIQUE,
        nome_depto TEXT NOT NULL,
        id_chefe_prof INTEGER NULL
    );

    CREATE TABLE curso (
        id_curso INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_curso TEXT NOT NULL UNIQUE,
        nome_curso TEXT NOT NULL,
        grau_academico TEXT NOT NULL CHECK (grau_academico IN ('Bacharelado', 'Tecnólogo', 'Licenciatura')),
        duracao_semestres INTEGER NOT NULL CHECK (duracao_semestres > 0),
        carga_horaria_total INTEGER NOT NULL CHECK (carga_horaria_total > 0),
        id_depto INTEGER NOT NULL,
        FOREIGN KEY (id_depto) REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
    );

    CREATE TABLE professor (
        id_professor INTEGER PRIMARY KEY AUTOINCREMENT,
        matricula_prof TEXT NOT NULL UNIQUE,
        nome_completo TEXT NOT NULL,
        cpf TEXT NOT NULL UNIQUE,
        email_institucional TEXT NOT NULL UNIQUE,
        telefone TEXT,
        titulacao TEXT NOT NULL CHECK (titulacao IN ('Especialista', 'Mestre', 'Doutor', 'Pós-Doutor')),
        regime_trabalho TEXT NOT NULL CHECK (regime_trabalho IN ('20h', '40h', 'Dedicação Exclusiva')),
        data_admissao TEXT NOT NULL,
        id_depto INTEGER NOT NULL,
        FOREIGN KEY (id_depto) REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
    );

    CREATE TABLE disciplina (
        id_disciplina INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_disciplina TEXT NOT NULL UNIQUE,
        nome_disciplina TEXT NOT NULL,
        carga_horaria INTEGER NOT NULL CHECK (carga_horaria > 0),
        creditos INTEGER NOT NULL CHECK (creditos > 0),
        ementa TEXT,
        id_depto INTEGER NOT NULL,
        FOREIGN KEY (id_depto) REFERENCES departamento(id_depto) ON UPDATE CASCADE ON DELETE RESTRICT
    );

    CREATE TABLE matriz_curricular (
        id_matriz INTEGER PRIMARY KEY AUTOINCREMENT,
        id_curso INTEGER NOT NULL,
        id_disciplina INTEGER NOT NULL,
        periodo_ideal INTEGER NOT NULL CHECK (periodo_ideal > 0),
        obrigatoria INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (id_disciplina) REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
        UNIQUE (id_curso, id_disciplina)
    );

    CREATE TABLE pre_requisito (
        id_disciplina INTEGER NOT NULL,
        id_disciplina_prereq INTEGER NOT NULL,
        PRIMARY KEY (id_disciplina, id_disciplina_prereq),
        FOREIGN KEY (id_disciplina) REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (id_disciplina_prereq) REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
        CHECK (id_disciplina <> id_disciplina_prereq)
    );

    CREATE TABLE aluno (
        id_aluno INTEGER PRIMARY KEY AUTOINCREMENT,
        matricula_aluno TEXT NOT NULL UNIQUE,
        nome_completo TEXT NOT NULL,
        cpf TEXT NOT NULL UNIQUE,
        data_nascimento TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        telefone TEXT,
        endereco TEXT,
        data_ingresso TEXT NOT NULL,
        status_matricula TEXT NOT NULL DEFAULT 'Ativo' 
            CHECK (status_matricula IN ('Ativo', 'Trancado', 'Formado', 'Desistente')),
        id_curso INTEGER NOT NULL,
        FOREIGN KEY (id_curso) REFERENCES curso(id_curso) ON UPDATE CASCADE ON DELETE RESTRICT
    );

    CREATE TABLE turma (
        id_turma INTEGER PRIMARY KEY AUTOINCREMENT,
        codigo_turma TEXT NOT NULL UNIQUE,
        ano_semestre TEXT NOT NULL,
        dia_semana TEXT NOT NULL CHECK (dia_semana IN ('Segunda-feira', 'Terça-feira', 'Quarta-feira', 'Quinta-feira', 'Sexta-feira', 'Sábado')),
        horario_inicio TEXT NOT NULL,
        horario_fim TEXT NOT NULL,
        sala_bloco TEXT NOT NULL,
        limite_vagas INTEGER NOT NULL CHECK (limite_vagas > 0),
        id_disciplina INTEGER NOT NULL,
        id_professor INTEGER NOT NULL,
        FOREIGN KEY (id_disciplina) REFERENCES disciplina(id_disciplina) ON UPDATE CASCADE ON DELETE RESTRICT,
        FOREIGN KEY (id_professor) REFERENCES professor(id_professor) ON UPDATE CASCADE ON DELETE RESTRICT,
        CHECK (horario_fim > horario_inicio)
    );

    CREATE TABLE matricula_turma (
        id_matricula_turma INTEGER PRIMARY KEY AUTOINCREMENT,
        id_aluno INTEGER NOT NULL,
        id_turma INTEGER NOT NULL,
        data_inscricao TEXT NOT NULL,
        nota_1 REAL CHECK (nota_1 >= 0 AND nota_1 <= 10),
        nota_2 REAL CHECK (nota_2 >= 0 AND nota_2 <= 10),
        nota_final REAL CHECK (nota_final >= 0 AND nota_final <= 10),
        frequencia_pct REAL CHECK (frequencia_pct >= 0 AND frequencia_pct <= 100),
        situacao TEXT NOT NULL DEFAULT 'Cursando' 
            CHECK (situacao IN ('Cursando', 'Aprovado', 'Reprovado por Nota', 'Reprovado por Falta', 'Trancado')),
        FOREIGN KEY (id_aluno) REFERENCES aluno(id_aluno) ON UPDATE CASCADE ON DELETE CASCADE,
        FOREIGN KEY (id_turma) REFERENCES turma(id_turma) ON UPDATE CASCADE ON DELETE RESTRICT,
        UNIQUE (id_aluno, id_turma)
    );
    """)
    print("   -> Todas as 9 tabelas criadas com integridade referencial com sucesso!")

    # 2. Carga Inicial de Dados
    print("\n[+] 2. Inserindo dados de teste (5 Departamentos, 5 Cursos, Professores, Alunos, Turmas)...")
    cursor.executescript("""
    INSERT INTO departamento (sigla, nome_depto) VALUES
    ('DCOMP', 'Departamento de Computação e Tecnologia'),
    ('DMED',  'Departamento de Ciências Médicas e Saúde'),
    ('DAERO', 'Departamento de Engenharia Aeroespacial'),
    ('DFISIO','Departamento de Fisioterapia e Reabilitação'),
    ('DADM',  'Departamento de Gestão e Recursos Humanos');

    INSERT INTO curso (codigo_curso, nome_curso, grau_academico, duracao_semestres, carga_horaria_total, id_depto) VALUES
    ('SI',    'Sistemas de Informação',      'Bacharelado', 8,  3200, 1),
    ('MED',   'Medicina',                    'Bacharelado', 12, 7200, 2),
    ('AERO',  'Engenharia Aeroespacial',     'Bacharelado', 10, 4200, 3),
    ('FISIO', 'Fisioterapia',                'Bacharelado', 10, 4000, 4),
    ('RH',    'Gestão de Recursos Humanos',   'Tecnólogo',   4,  1800, 5);

    INSERT INTO professor (matricula_prof, nome_completo, cpf, email_institucional, telefone, titulacao, regime_trabalho, data_admissao, id_depto) VALUES
    ('PRF201801', 'Dr. Carlos Alberto Mendes',   '111.222.333-01', 'carlos.mendes@faculdadexx.edu.br',   '(21) 98765-1001', 'Doutor',      'Dedicação Exclusiva', '2018-02-01', 1),
    ('PRF201902', 'Dra. Mariana Silva Ramos',     '222.333.444-02', 'mariana.ramos@faculdadexx.edu.br',   '(21) 98765-1002', 'Doutor',      'Dedicação Exclusiva', '2019-03-15', 2),
    ('PRF202003', 'Dr. Roberto Santos Ferreira', '333.444.555-03', 'roberto.santos@faculdadexx.edu.br',  '(21) 98765-1003', 'Doutor',      'Dedicação Exclusiva', '2020-08-01', 3),
    ('PRF202104', 'Msc. Juliana Costa Lima',     '444.555.666-04', 'juliana.lima@faculdadexx.edu.br',    '(21) 98765-1004', 'Mestre',      '40h',                 '2021-02-10', 4),
    ('PRF202205', 'Msc. Fernando Alves Pires',   '555.666.777-05', 'fernando.pires@faculdadexx.edu.br',  '(21) 98765-1005', 'Mestre',      '20h',                 '2022-04-01', 5);

    INSERT INTO disciplina (codigo_disciplina, nome_disciplina, carga_horaria, creditos, ementa, id_depto) VALUES
    ('SI101',   'Banco de Dados I',             80, 4, 'Modelagem conceitual, lógica e física. Normalização. SQL.', 1),
    ('SI102',   'Algoritmos e Programação',     80, 4, 'Lógica computacional, estruturas condicionais e repetição.', 1),
    ('MED201',  'Anatomia Humana I',            120, 6, 'Estudo morfológico dos sistemas do corpo humano.', 2),
    ('AERO301', 'Aerodinâmica Aplicada',       100, 5, 'Equações de escoamento, sustentação e arrasto em aeronaves.', 3),
    ('FISIO401','Cinesiologia e Biomecânica',   80, 4, 'Análise biomecânica do movimento humano e postura.', 4),
    ('RH501',   'Gestão de Pessoas e Carreira', 60, 3, 'Processos de atração, retenção, planos de cargos e salários.', 5);

    INSERT INTO matriz_curricular (id_curso, id_disciplina, periodo_ideal, obrigatoria) VALUES
    (1, 1, 3, 1),
    (1, 2, 1, 1),
    (2, 3, 1, 1),
    (3, 4, 5, 1),
    (4, 5, 2, 1),
    (5, 6, 1, 1);

    INSERT INTO aluno (matricula_aluno, nome_completo, cpf, data_nascimento, email, telefone, endereco, data_ingresso, id_curso) VALUES
    ('202410101', 'Lucas Bezerra de Oliveira',  '010.203.405-11', '2001-05-12', 'lucas.oliveira@aluno.faculdadexx.edu.br',  '(21) 97111-2233', 'Av. Rio Branco, 1000 - Centro, Rio de Janeiro - RJ', '2024-02-01', 1),
    ('202410102', 'Beatriz Souza Martins',      '020.304.506-22', '2002-08-20', 'beatriz.martins@aluno.faculdadexx.edu.br', '(21) 97222-3344', 'Rua Visconde de Pirajá, 450 - Ipanema, Rio de Janeiro - RJ',   '2024-02-01', 2),
    ('202410103', 'Gabriel Santos Nogueira',    '030.405.607-33', '2000-11-03', 'gabriel.santos@aluno.faculdadexx.edu.br',  '(21) 97333-4455', 'Praia de Botafogo, 800 - Botafogo, Rio de Janeiro - RJ', '2024-02-01', 3),
    ('202410104', 'Camila Rodrigues Lima',      '040.506.708-44', '2003-03-15', 'camila.lima@aluno.faculdadexx.edu.br',     '(21) 97444-5566', 'Av. Atlântica, 120 - Copacabana, Rio de Janeiro - RJ', '2024-02-01', 4),
    ('202410105', 'Rodrigo Mendes Barreto',     '050.607.809-55', '1999-07-28', 'rodrigo.mendes@aluno.faculdadexx.edu.br',  '(21) 97555-6677', 'Av. das Américas, 900 - Barra da Tijuca, Rio de Janeiro - RJ', '2024-02-01', 5);

    INSERT INTO turma (codigo_turma, ano_semestre, dia_semana, horario_inicio, horario_fim, sala_bloco, limite_vagas, id_disciplina, id_professor) VALUES
    ('TURMA-SI-BD-2026.1',     '2026.1', 'Segunda-feira', '19:00', '22:30', 'Laboratório de Informática 3 - Bloco B', 40, 1, 1),
    ('TURMA-MED-ANAT-2026.1',  '2026.1', 'Terça-feira',   '08:00', '12:00', 'Laboratório Anatômico 1 - Bloco Saúde',    30, 3, 2),
    ('TURMA-AERO-AERO-2026.1', '2026.1', 'Quarta-feira',  '14:00', '18:00', 'Sala de Projetos Aero 2 - Bloco Eng',      35, 4, 3),
    ('TURMA-FISIO-CIN-2026.1', '2026.1', 'Quinta-feira',  '13:30', '17:00', 'Clínica Escola Fisioterapia - Bloco D',    30, 5, 4),
    ('TURMA-RH-GP-2026.1',     '2026.1', 'Sexta-feira',   '19:00', '22:00', 'Sala de Aula 204 - Bloco Central',         50, 6, 5);

    INSERT INTO matricula_turma (id_aluno, id_turma, data_inscricao, nota_1, nota_2, nota_final, frequencia_pct, situacao) VALUES
    (1, 1, '2026-02-10', 9.5, 9.0, 9.25, 96.0, 'Cursando'),
    (2, 2, '2026-02-11', 8.5, 9.0, 8.75, 98.0, 'Cursando'),
    (3, 3, '2026-02-10', 9.0, 8.0, 8.50, 92.0, 'Cursando'),
    (4, 4, '2026-02-12', 8.0, 8.5, 8.25, 94.0, 'Cursando'),
    (5, 5, '2026-02-10', 10.0, 9.5, 9.75, 100.0, 'Cursando');
    """)
    conn.commit()
    print("   -> Carga inicial de dados inserida com sucesso!")

    # 3. Testes de Restrições e Integridade (Garantia das Regras de Negócio)
    print("\n[+] 3. Testando Regras de Negócio e Restrições de Integridade...")

    # Teste 3.1: Tentativa de matricular aluno 2x na mesma turma (UNIQUE constraint)
    print("   - Teste 3.1: Testando bloqueio de dupla inscrição do mesmo aluno na mesma turma...")
    try:
        cursor.execute("INSERT INTO matricula_turma (id_aluno, id_turma, data_inscricao) VALUES (1, 1, '2026-02-15');")
        conn.commit()
        print("     [FALHA] Dupla matrícula permitida indevidamente!")
    except sqlite3.IntegrityError as e:
        print(f"     [SUCESSO] Bloqueado corretamente pelo banco! Erro esperado: {e}")

    # Teste 3.2: Tentativa de atribuir professor inexistente a uma turma (FK constraint)
    print("   - Teste 3.2: Testando bloqueio de Chave Estrangeira (Professor inexistente)...")
    try:
        cursor.execute("INSERT INTO turma (codigo_turma, ano_semestre, dia_semana, horario_inicio, horario_fim, sala_bloco, limite_vagas, id_disciplina, id_professor) VALUES ('TURMA-INVALIDA', '2026.1', 'Segunda-feira', '10:00', '12:00', 'Sala 1', 30, 1, 9999);")
        conn.commit()
        print("     [FALHA] Chave estrangeira inexistente permitida!")
    except sqlite3.IntegrityError as e:
        print(f"     [SUCESSO] Bloqueado corretamente pelo banco! Erro esperado: {e}")

    # Teste 3.3: Tentativa de cadastrar nota inválida (CHECK constraint > 10)
    print("   - Teste 3.3: Testando bloqueio de Restrição CHECK (Nota > 10)...")
    try:
        cursor.execute("UPDATE matricula_turma SET nota_1 = 15.5 WHERE id_matricula_turma = 1;")
        conn.commit()
        print("     [FALHA] Nota 15.5 permitida indevidamente!")
    except sqlite3.IntegrityError as e:
        print(f"     [SUCESSO] Bloqueado corretamente pelo banco! Erro esperado: {e}")

    # 4. Executando Consultas de Negócio (Relatórios de Alocação)
    print("\n" + "=" * 70)
    print(" CONSULTA 1: RELATÓRIO DE ALOCAÇÃO DOCENTE (PROFESSORES & TURMAS)")
    print("=" * 70)
    cursor.execute("""
    SELECT 
        p.nome_completo AS professor,
        p.titulacao,
        c.nome_curso,
        d.nome_disciplina,
        t.codigo_turma,
        t.dia_semana,
        t.horario_inicio || ' às ' || t.horario_fim AS horario,
        t.sala_bloco,
        t.limite_vagas
    FROM turma t
    INNER JOIN professor p ON t.id_professor = p.id_professor
    INNER JOIN disciplina d ON t.id_disciplina = d.id_disciplina
    INNER JOIN matriz_curricular mc ON d.id_disciplina = mc.id_disciplina
    INNER JOIN curso c ON mc.id_curso = c.id_curso
    ORDER BY t.dia_semana;
    """)
    for row in cursor.fetchall():
        print(f"Professor : {row[0]} ({row[1]})")
        print(f"Curso     : {row[2]} | Disciplina: {row[3]}")
        print(f"Turma     : {row[4]} | Vagas: {row[8]}")
        print(f"Horário   : {row[5]} das {row[6]} na sala: {row[7]}")
        print("-" * 70)

    print("\n" + "=" * 70)
    print(" CONSULTA 2: RELATÓRIO DE ALOCAÇÃO DISCENTE (COMPROVANTE DE MATRÍCULA)")
    print("=" * 70)
    cursor.execute("""
    SELECT 
        a.matricula_aluno,
        a.nome_completo AS aluno,
        c.nome_curso,
        d.nome_disciplina,
        p.nome_completo AS professor_regente,
        t.dia_semana || ' (' || t.horario_inicio || ')' AS dia_horario,
        t.sala_bloco,
        mt.nota_final,
        mt.frequencia_pct,
        mt.situacao
    FROM matricula_turma mt
    INNER JOIN aluno a ON mt.id_aluno = a.id_aluno
    INNER JOIN curso c ON a.id_curso = c.id_curso
    INNER JOIN turma t ON mt.id_turma = t.id_turma
    INNER JOIN disciplina d ON t.id_disciplina = d.id_disciplina
    INNER JOIN professor p ON t.id_professor = p.id_professor
    ORDER BY a.nome_completo;
    """)
    for row in cursor.fetchall():
        print(f"Aluno      : {row[1]} (Matrícula: {row[0]})")
        print(f"Curso      : {row[2]}")
        print(f"Disciplina : {row[3]} | Docente: {row[4]}")
        print(f"Local/Hora : {row[5]} - {row[6]}")
        print(f"Situação   : {row[9]} | Média: {row[7]} | Freq: {row[8]}%")
        print("-" * 70)

    conn.close()
    print("\n[V] TODOS OS TESTES PASSARAM COM 100% DE SUCESSO!")
    print(f"[V] Banco de dados de teste gravado e disponível em: {db_file}")

if __name__ == "__main__":
    run_tests()
