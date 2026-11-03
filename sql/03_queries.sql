-- ==============================================================================
-- FACULDADE XX — SISTEMA DE ALOCAÇÃO DE ALUNOS E PROFESSORES
-- 03_QUERIES.SQL — CONSULTAS ANALÍTICAS E RELATÓRIOS GERENCIAIS
-- ==============================================================================

-- Consulta 1: Relatório de Alocação Docente (Quais turmas e disciplinas cada professor ministra)
SELECT 
    p.matricula_prof,
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
ORDER BY t.dia_semana, t.horario_inicio;

-- Consulta 2: Relatório de Alocação Discente (Comprovante de Horário / Espelho de Matrícula)
SELECT 
    a.matricula_aluno,
    a.nome_completo AS aluno,
    c.nome_curso,
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

-- Consulta 3: Taxa de Ocupação de Turmas (Prevenção de Superlotação)
SELECT 
    t.codigo_turma,
    d.nome_disciplina,
    t.limite_vagas AS capacidade_maxima,
    COUNT(mt.id_aluno) AS alunos_matriculados,
    (t.limite_vagas - COUNT(mt.id_aluno)) AS vagas_restantes,
    ROUND((COUNT(mt.id_aluno)::numeric / t.limite_vagas) * 100, 2) AS taxa_ocupacao_pct
FROM turma t
INNER JOIN disciplina d ON t.id_disciplina = d.id_disciplina
LEFT JOIN matricula_turma mt ON t.id_turma = mt.id_turma
GROUP BY t.id_turma, t.codigo_turma, d.nome_disciplina, t.limite_vagas
ORDER BY taxa_ocupacao_pct DESC;
