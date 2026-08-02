-- ============================================================
-- CastroEduConnect — Complete Database Schema (FIXED)
-- Run this in your Supabase SQL Editor (Project > SQL Editor > New query)
-- Safe to re-run: drops existing objects first.
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------
-- CLEAN SLATE (safe re-run)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS public.analytics_daily CASCADE;
DROP TABLE IF EXISTS public.system_settings CASCADE;
DROP TABLE IF EXISTS public.audit_logs CASCADE;
DROP TABLE IF EXISTS public.activity_logs CASCADE;
DROP TABLE IF EXISTS public.notifications CASCADE;
DROP TABLE IF EXISTS public.announcements CASCADE;
DROP TABLE IF EXISTS public.discussion_comments CASCADE;
DROP TABLE IF EXISTS public.discussions CASCADE;
DROP TABLE IF EXISTS public.resource_comments CASCADE;
DROP TABLE IF EXISTS public.resource_likes CASCADE;
DROP TABLE IF EXISTS public.resource_bookmarks CASCADE;
DROP TABLE IF EXISTS public.resources CASCADE;
DROP TABLE IF EXISTS public.answers CASCADE;
DROP TABLE IF EXISTS public.submissions CASCADE;
DROP TABLE IF EXISTS public.matching_pairs CASCADE;
DROP TABLE IF EXISTS public.choices CASCADE;
DROP TABLE IF EXISTS public.questions CASCADE;
DROP TABLE IF EXISTS public.question_bank CASCADE;
DROP TABLE IF EXISTS public.assessments CASCADE;
DROP TABLE IF EXISTS public.sub_topics CASCADE;
DROP TABLE IF EXISTS public.topics CASCADE;
DROP TABLE IF EXISTS public.subject_enrollments CASCADE;
DROP TABLE IF EXISTS public.class_enrollments CASCADE;
DROP TABLE IF EXISTS public.subjects CASCADE;
DROP TABLE IF EXISTS public.classes CASCADE;
DROP TABLE IF EXISTS public.grades CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- ------------------------------------------------------------
-- PROFILES (extends auth.users)
-- ------------------------------------------------------------
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL DEFAULT '',
    last_name TEXT NOT NULL DEFAULT '',
    role TEXT NOT NULL DEFAULT 'learner' CHECK (role IN ('admin', 'teacher', 'learner')),
    avatar_url TEXT,
    phone TEXT,
    bio TEXT,
    grade_id UUID,
    class_id UUID,
    date_of_birth DATE,
    address TEXT,
    city TEXT,
    country TEXT,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- GRADES
-- ------------------------------------------------------------
CREATE TABLE public.grades (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    sort_order INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- CLASSES
-- ------------------------------------------------------------
CREATE TABLE public.classes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    grade_id UUID REFERENCES public.grades(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    room_number TEXT,
    capacity INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_grade FOREIGN KEY (grade_id) REFERENCES public.grades(id) ON DELETE SET NULL;
ALTER TABLE public.profiles ADD CONSTRAINT fk_profiles_class FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE SET NULL;

-- ------------------------------------------------------------
-- CLASS ENROLLMENTS
-- ------------------------------------------------------------
CREATE TABLE public.class_enrollments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    class_id UUID REFERENCES public.classes(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'dropped', 'completed')),
    UNIQUE(class_id, learner_id)
);

-- ------------------------------------------------------------
-- SUBJECTS
-- ------------------------------------------------------------
CREATE TABLE public.subjects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    grade_id UUID REFERENCES public.grades(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    class_id UUID REFERENCES public.classes(id) ON DELETE SET NULL,
    color TEXT DEFAULT '#2563EB',
    icon TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- SUBJECT ENROLLMENTS
-- ------------------------------------------------------------
CREATE TABLE public.subject_enrollments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'dropped', 'completed')),
    UNIQUE(subject_id, learner_id)
);

-- ------------------------------------------------------------
-- TOPICS & SUB-TOPICS
-- ------------------------------------------------------------
CREATE TABLE public.topics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.sub_topics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    topic_id UUID REFERENCES public.topics(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT,
    video_url TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- ASSESSMENTS (assignments / quizzes / CATs / exams)
-- ------------------------------------------------------------
CREATE TABLE public.assessments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    grade_id UUID REFERENCES public.grades(id),
    class_id UUID REFERENCES public.classes(id),
    assessment_type TEXT NOT NULL DEFAULT 'assignment' CHECK (assessment_type IN ('assignment', 'quiz', 'cat', 'exam')),
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'active', 'closed', 'archived')),
    opening_date TIMESTAMP WITH TIME ZONE,
    closing_date TIMESTAMP WITH TIME ZONE,
    time_limit INTEGER,
    total_marks INTEGER DEFAULT 100,
    passing_mark INTEGER DEFAULT 50,
    attempts_allowed INTEGER DEFAULT 1,
    instructions TEXT,
    randomize_questions BOOLEAN DEFAULT false,
    shuffle_answers BOOLEAN DEFAULT false,
    show_answers_after_submission BOOLEAN DEFAULT false,
    allow_calculator BOOLEAN DEFAULT false,
    question_count INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- QUESTION BANK
-- ------------------------------------------------------------
CREATE TABLE public.question_bank (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false', 'essay', 'short_answer', 'matching', 'fill_blank')),
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard', 'expert')),
    marks INTEGER DEFAULT 1,
    correct_answer TEXT,
    explanation TEXT,
    hint TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- QUESTIONS (belong to a specific assessment)
-- ------------------------------------------------------------
CREATE TABLE public.questions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE,
    question_bank_id UUID REFERENCES public.question_bank(id) ON DELETE SET NULL,
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL DEFAULT 'multiple_choice' CHECK (question_type IN ('multiple_choice', 'true_false', 'essay', 'short_answer', 'matching', 'fill_blank')),
    marks INTEGER DEFAULT 1,
    correct_answer TEXT,
    explanation TEXT,
    hint TEXT,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- CHOICES (for multiple choice questions)
-- ------------------------------------------------------------
CREATE TABLE public.choices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    choice_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- MATCHING PAIRS
-- ------------------------------------------------------------
CREATE TABLE public.matching_pairs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    left_text TEXT NOT NULL,
    right_text TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- SUBMISSIONS  (note: 'pending' added — used by app for essay grading queue)
-- ------------------------------------------------------------
CREATE TABLE public.submissions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    submitted_at TIMESTAMP WITH TIME ZONE,
    time_taken INTEGER,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'submitted', 'pending', 'grading', 'graded', 'returned')),
    total_score DECIMAL(6,2),
    total_marks INTEGER,
    percentage DECIMAL(5,2),
    grade TEXT,
    passed BOOLEAN,
    feedback TEXT,
    teacher_comment TEXT,
    teacher_id UUID REFERENCES public.profiles(id),
    graded_at TIMESTAMP WITH TIME ZONE,
    attempt_number INTEGER DEFAULT 1,
    is_late BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- ANSWERS
-- ------------------------------------------------------------
CREATE TABLE public.answers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    submission_id UUID REFERENCES public.submissions(id) ON DELETE CASCADE,
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    answer_text TEXT,
    selected_choice_id UUID REFERENCES public.choices(id),
    matching_pairs JSONB,
    is_correct BOOLEAN DEFAULT false,
    score DECIMAL(5,2),
    teacher_comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- RESOURCES
-- ------------------------------------------------------------
CREATE TABLE public.resources (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    topic_id UUID REFERENCES public.topics(id) ON DELETE SET NULL,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    file_url TEXT NOT NULL,
    file_type TEXT DEFAULT 'other' CHECK (file_type IN ('pdf', 'word', 'powerpoint', 'image', 'video', 'audio', 'zip', 'other')),
    file_size BIGINT,
    is_published BOOLEAN DEFAULT true,
    download_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.resource_bookmarks (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    resource_id UUID REFERENCES public.resources(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(resource_id, learner_id)
);

CREATE TABLE public.resource_likes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    resource_id UUID REFERENCES public.resources(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(resource_id, user_id)
);

CREATE TABLE public.resource_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    resource_id UUID REFERENCES public.resources(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- DISCUSSION FORUM
-- ------------------------------------------------------------
CREATE TABLE public.discussions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    content TEXT,
    is_pinned BOOLEAN DEFAULT false,
    is_closed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.discussion_comments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    discussion_id UUID REFERENCES public.discussions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES public.discussion_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_best_answer BOOLEAN DEFAULT false,
    upvotes INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- ANNOUNCEMENTS
-- ------------------------------------------------------------
CREATE TABLE public.announcements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    target_role TEXT DEFAULT 'all' CHECK (target_role IN ('all', 'admin', 'teacher', 'learner')),
    target_grade_id UUID REFERENCES public.grades(id),
    target_class_id UUID REFERENCES public.classes(id),
    target_subject_id UUID REFERENCES public.subjects(id),
    priority TEXT DEFAULT 'update' CHECK (priority IN ('important', 'update', 'reminder')),
    is_pinned BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- NOTIFICATIONS
-- ------------------------------------------------------------
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('assignment', 'exam', 'grade', 'feedback', 'announcement', 'deadline', 'discussion', 'system')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    link TEXT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ------------------------------------------------------------
-- LOGS / SETTINGS / ANALYTICS
-- ------------------------------------------------------------
CREATE TABLE public.activity_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    details JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    admin_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    target_user_id UUID REFERENCES public.profiles(id),
    details JSONB,
    ip_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.system_settings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    key TEXT UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    category TEXT,
    is_public BOOLEAN DEFAULT false,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE public.analytics_daily (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    date DATE NOT NULL,
    total_users INTEGER DEFAULT 0,
    total_learners INTEGER DEFAULT 0,
    total_teachers INTEGER DEFAULT 0,
    total_admins INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    submissions_count INTEGER DEFAULT 0,
    assessments_created INTEGER DEFAULT 0,
    UNIQUE(date)
);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subject_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sub_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_bank ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.choices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matching_pairs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussion_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_daily ENABLE ROW LEVEL SECURITY;

-- Helper: is the current user an admin?
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin');
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Helper: is the current user a teacher?
CREATE OR REPLACE FUNCTION public.is_teacher()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'teacher');
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ---------------- PROFILES ----------------
CREATE POLICY "profiles_select_all" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update_own" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "profiles_update_admin" ON public.profiles FOR UPDATE USING (public.is_admin());
CREATE POLICY "profiles_insert_own" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_delete_admin" ON public.profiles FOR DELETE USING (public.is_admin());

-- ---------------- GRADES ----------------
CREATE POLICY "grades_select_all" ON public.grades FOR SELECT USING (true);
CREATE POLICY "grades_write_admin" ON public.grades FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------- CLASSES ----------------
CREATE POLICY "classes_select_all" ON public.classes FOR SELECT USING (true);
CREATE POLICY "classes_write_admin" ON public.classes FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------- CLASS ENROLLMENTS ----------------
CREATE POLICY "class_enrollments_select_all" ON public.class_enrollments FOR SELECT USING (true);
CREATE POLICY "class_enrollments_insert_own" ON public.class_enrollments FOR INSERT WITH CHECK (auth.uid() = learner_id OR public.is_admin());
CREATE POLICY "class_enrollments_manage_admin" ON public.class_enrollments FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ---------------- SUBJECTS ----------------
CREATE POLICY "subjects_select_all" ON public.subjects FOR SELECT USING (true);
CREATE POLICY "subjects_insert_staff" ON public.subjects FOR INSERT WITH CHECK (public.is_admin() OR public.is_teacher());
CREATE POLICY "subjects_update_owner" ON public.subjects FOR UPDATE USING (auth.uid() = teacher_id OR public.is_admin());
CREATE POLICY "subjects_delete_owner" ON public.subjects FOR DELETE USING (auth.uid() = teacher_id OR public.is_admin());

-- ---------------- SUBJECT ENROLLMENTS ----------------
CREATE POLICY "subject_enrollments_select_all" ON public.subject_enrollments FOR SELECT USING (true);
CREATE POLICY "subject_enrollments_insert_own" ON public.subject_enrollments FOR INSERT WITH CHECK (auth.uid() = learner_id OR public.is_admin());
CREATE POLICY "subject_enrollments_delete_own" ON public.subject_enrollments FOR DELETE USING (auth.uid() = learner_id OR public.is_admin());

-- ---------------- TOPICS / SUB-TOPICS ----------------
CREATE POLICY "topics_select_all" ON public.topics FOR SELECT USING (true);
CREATE POLICY "topics_write_staff" ON public.topics FOR ALL USING (
    public.is_admin() OR auth.uid() IN (SELECT teacher_id FROM public.subjects WHERE id = subject_id)
) WITH CHECK (
    public.is_admin() OR auth.uid() IN (SELECT teacher_id FROM public.subjects WHERE id = subject_id)
);

CREATE POLICY "subtopics_select_all" ON public.sub_topics FOR SELECT USING (true);
CREATE POLICY "subtopics_write_staff" ON public.sub_topics FOR ALL USING (
    public.is_admin() OR auth.uid() IN (
        SELECT s.teacher_id FROM public.subjects s JOIN public.topics t ON t.subject_id = s.id WHERE t.id = topic_id
    )
) WITH CHECK (
    public.is_admin() OR auth.uid() IN (
        SELECT s.teacher_id FROM public.subjects s JOIN public.topics t ON t.subject_id = s.id WHERE t.id = topic_id
    )
);

-- ---------------- ASSESSMENTS ----------------
CREATE POLICY "assessments_select_all" ON public.assessments FOR SELECT USING (true);
CREATE POLICY "assessments_insert_staff" ON public.assessments FOR INSERT WITH CHECK (auth.uid() = teacher_id OR public.is_admin());
CREATE POLICY "assessments_update_owner" ON public.assessments FOR UPDATE USING (auth.uid() = teacher_id OR public.is_admin());
CREATE POLICY "assessments_delete_owner" ON public.assessments FOR DELETE USING (auth.uid() = teacher_id OR public.is_admin());

-- ---------------- QUESTION BANK ----------------
CREATE POLICY "question_bank_select_all" ON public.question_bank FOR SELECT USING (true);
CREATE POLICY "question_bank_write_owner" ON public.question_bank FOR ALL USING (auth.uid() = teacher_id OR public.is_admin()) WITH CHECK (auth.uid() = teacher_id OR public.is_admin());

-- ---------------- QUESTIONS ----------------
CREATE POLICY "questions_select_all" ON public.questions FOR SELECT USING (true);
CREATE POLICY "questions_write_owner" ON public.questions FOR ALL USING (
    public.is_admin() OR auth.uid() IN (SELECT teacher_id FROM public.assessments WHERE id = assessment_id)
) WITH CHECK (
    public.is_admin() OR auth.uid() IN (SELECT teacher_id FROM public.assessments WHERE id = assessment_id)
);

-- ---------------- CHOICES ----------------
CREATE POLICY "choices_select_all" ON public.choices FOR SELECT USING (true);
CREATE POLICY "choices_write_owner" ON public.choices FOR ALL USING (
    public.is_admin() OR auth.uid() IN (
        SELECT a.teacher_id FROM public.assessments a JOIN public.questions q ON q.assessment_id = a.id WHERE q.id = question_id
    )
) WITH CHECK (
    public.is_admin() OR auth.uid() IN (
        SELECT a.teacher_id FROM public.assessments a JOIN public.questions q ON q.assessment_id = a.id WHERE q.id = question_id
    )
);

-- ---------------- MATCHING PAIRS ----------------
CREATE POLICY "matching_pairs_select_all" ON public.matching_pairs FOR SELECT USING (true);
CREATE POLICY "matching_pairs_write_owner" ON public.matching_pairs FOR ALL USING (
    public.is_admin() OR auth.uid() IN (
        SELECT a.teacher_id FROM public.assessments a JOIN public.questions q ON q.assessment_id = a.id WHERE q.id = question_id
    )
) WITH CHECK (
    public.is_admin() OR auth.uid() IN (
        SELECT a.teacher_id FROM public.assessments a JOIN public.questions q ON q.assessment_id = a.id WHERE q.id = question_id
    )
);

-- ---------------- SUBMISSIONS ----------------
CREATE POLICY "submissions_select_own_or_teacher" ON public.submissions FOR SELECT USING (
    auth.uid() = learner_id
    OR public.is_admin()
    OR auth.uid() IN (SELECT teacher_id FROM public.assessments WHERE id = assessment_id)
);
CREATE POLICY "submissions_insert_own" ON public.submissions FOR INSERT WITH CHECK (auth.uid() = learner_id);
CREATE POLICY "submissions_update_own" ON public.submissions FOR UPDATE USING (auth.uid() = learner_id);
CREATE POLICY "submissions_update_teacher" ON public.submissions FOR UPDATE USING (
    public.is_admin() OR auth.uid() IN (SELECT teacher_id FROM public.assessments WHERE id = assessment_id)
);

-- ---------------- ANSWERS ----------------
CREATE POLICY "answers_select_own_or_teacher" ON public.answers FOR SELECT USING (
    public.is_admin()
    OR auth.uid() IN (SELECT learner_id FROM public.submissions WHERE id = submission_id)
    OR auth.uid() IN (
        SELECT a.teacher_id FROM public.assessments a JOIN public.submissions s ON s.assessment_id = a.id WHERE s.id = submission_id
    )
);
CREATE POLICY "answers_insert_own" ON public.answers FOR INSERT WITH CHECK (
    auth.uid() IN (SELECT learner_id FROM public.submissions WHERE id = submission_id)
);
CREATE POLICY "answers_update_teacher_or_own" ON public.answers FOR UPDATE USING (
    public.is_admin()
    OR auth.uid() IN (SELECT learner_id FROM public.submissions WHERE id = submission_id)
    OR auth.uid() IN (
        SELECT a.teacher_id FROM public.assessments a JOIN public.submissions s ON s.assessment_id = a.id WHERE s.id = submission_id
    )
);

-- ---------------- RESOURCES ----------------
CREATE POLICY "resources_select_all" ON public.resources FOR SELECT USING (true);
CREATE POLICY "resources_insert_staff" ON public.resources FOR INSERT WITH CHECK (auth.uid() = teacher_id OR public.is_admin());
CREATE POLICY "resources_update_owner" ON public.resources FOR UPDATE USING (auth.uid() = teacher_id OR public.is_admin());
CREATE POLICY "resources_delete_owner" ON public.resources FOR DELETE USING (auth.uid() = teacher_id OR public.is_admin());

CREATE POLICY "resource_bookmarks_select_own" ON public.resource_bookmarks FOR SELECT USING (auth.uid() = learner_id);
CREATE POLICY "resource_bookmarks_manage_own" ON public.resource_bookmarks FOR ALL USING (auth.uid() = learner_id) WITH CHECK (auth.uid() = learner_id);

CREATE POLICY "resource_likes_select_all" ON public.resource_likes FOR SELECT USING (true);
CREATE POLICY "resource_likes_manage_own" ON public.resource_likes FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

CREATE POLICY "resource_comments_select_all" ON public.resource_comments FOR SELECT USING (true);
CREATE POLICY "resource_comments_insert_own" ON public.resource_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "resource_comments_manage_own" ON public.resource_comments FOR DELETE USING (auth.uid() = user_id OR public.is_admin());

-- ---------------- DISCUSSIONS ----------------
CREATE POLICY "discussions_select_all" ON public.discussions FOR SELECT USING (true);
CREATE POLICY "discussions_insert_auth" ON public.discussions FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "discussions_update_owner" ON public.discussions FOR UPDATE USING (auth.uid() = author_id OR public.is_admin() OR public.is_teacher());
CREATE POLICY "discussions_delete_owner" ON public.discussions FOR DELETE USING (auth.uid() = author_id OR public.is_admin());

CREATE POLICY "discussion_comments_select_all" ON public.discussion_comments FOR SELECT USING (true);
CREATE POLICY "discussion_comments_insert_auth" ON public.discussion_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "discussion_comments_update_owner" ON public.discussion_comments FOR UPDATE USING (auth.uid() = user_id OR public.is_admin() OR public.is_teacher());
CREATE POLICY "discussion_comments_delete_owner" ON public.discussion_comments FOR DELETE USING (auth.uid() = user_id OR public.is_admin());

-- ---------------- ANNOUNCEMENTS ----------------
CREATE POLICY "announcements_select_all" ON public.announcements FOR SELECT USING (true);
CREATE POLICY "announcements_write_staff" ON public.announcements FOR ALL USING (public.is_admin() OR public.is_teacher()) WITH CHECK (public.is_admin() OR public.is_teacher());

-- ---------------- NOTIFICATIONS ----------------
CREATE POLICY "notifications_manage_own" ON public.notifications FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ---------------- LOGS / SETTINGS / ANALYTICS (admin only) ----------------
CREATE POLICY "activity_logs_select_admin" ON public.activity_logs FOR SELECT USING (public.is_admin());
CREATE POLICY "activity_logs_insert_own" ON public.activity_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "audit_logs_admin_only" ON public.audit_logs FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "system_settings_select_public" ON public.system_settings FOR SELECT USING (is_public = true OR public.is_admin());
CREATE POLICY "system_settings_write_admin" ON public.system_settings FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

CREATE POLICY "analytics_daily_admin_only" ON public.analytics_daily FOR ALL USING (public.is_admin()) WITH CHECK (public.is_admin());

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_subjects_grade_id ON public.subjects(grade_id);
CREATE INDEX idx_subjects_teacher_id ON public.subjects(teacher_id);
CREATE INDEX idx_subject_enrollments_learner ON public.subject_enrollments(learner_id);
CREATE INDEX idx_subject_enrollments_subject ON public.subject_enrollments(subject_id);
CREATE INDEX idx_submissions_assessment_id ON public.submissions(assessment_id);
CREATE INDEX idx_submissions_learner_id ON public.submissions(learner_id);
CREATE INDEX idx_answers_submission_id ON public.answers(submission_id);
CREATE INDEX idx_answers_question_id ON public.answers(question_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_assessments_subject_id ON public.assessments(subject_id);
CREATE INDEX idx_assessments_teacher_id ON public.assessments(teacher_id);
CREATE INDEX idx_questions_assessment_id ON public.questions(assessment_id);
CREATE INDEX idx_choices_question_id ON public.choices(question_id);
CREATE INDEX idx_resources_subject_id ON public.resources(subject_id);
CREATE INDEX idx_resource_likes_resource_id ON public.resource_likes(resource_id);
CREATE INDEX idx_resource_comments_resource_id ON public.resource_comments(resource_id);
CREATE INDEX idx_announcements_author_id ON public.announcements(author_id);
CREATE INDEX idx_discussions_subject_id ON public.discussions(subject_id);
CREATE INDEX idx_discussion_comments_discussion_id ON public.discussion_comments(discussion_id);

-- ============================================================
-- TRIGGERS
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subjects_updated_at BEFORE UPDATE ON public.subjects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_assessments_updated_at BEFORE UPDATE ON public.assessments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_submissions_updated_at BEFORE UPDATE ON public.submissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_answers_updated_at BEFORE UPDATE ON public.answers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON public.resources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_topics_updated_at BEFORE UPDATE ON public.topics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subtopics_updated_at BEFORE UPDATE ON public.sub_topics FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_discussions_updated_at BEFORE UPDATE ON public.discussions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_discussion_comments_updated_at BEFORE UPDATE ON public.discussion_comments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-create profile on signup — reads first_name/last_name/role from signUp() metadata.
-- (Previous version of this trigger ignored the metadata and always created blank
--  'learner' profiles — fixed here so registration works correctly for all roles.)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    meta_role TEXT;
BEGIN
    meta_role := COALESCE(NEW.raw_user_meta_data->>'role', 'learner');
    IF meta_role NOT IN ('admin', 'teacher', 'learner') THEN
        meta_role := 'learner';
    END IF;

    INSERT INTO public.profiles (id, email, first_name, last_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'first_name', ''),
        COALESCE(NEW.raw_user_meta_data->>'last_name', ''),
        meta_role
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Keep resources.like_count in sync with resource_likes
CREATE OR REPLACE FUNCTION sync_resource_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.resources SET like_count = like_count + 1 WHERE id = NEW.resource_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.resources SET like_count = GREATEST(like_count - 1, 0) WHERE id = OLD.resource_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_resource_like_insert AFTER INSERT ON public.resource_likes FOR EACH ROW EXECUTE FUNCTION sync_resource_like_count();
CREATE TRIGGER trg_resource_like_delete AFTER DELETE ON public.resource_likes FOR EACH ROW EXECUTE FUNCTION sync_resource_like_count();

-- ============================================================
-- STORAGE BUCKET for resource uploads (resources.html uploads here)
-- ============================================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('resources', 'resources', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "resources_bucket_public_read" ON storage.objects
    FOR SELECT USING (bucket_id = 'resources');

CREATE POLICY "resources_bucket_authenticated_upload" ON storage.objects
    FOR INSERT WITH CHECK (bucket_id = 'resources' AND auth.role() = 'authenticated');

CREATE POLICY "resources_bucket_owner_update" ON storage.objects
    FOR UPDATE USING (bucket_id = 'resources' AND auth.uid() = owner);

CREATE POLICY "resources_bucket_owner_delete" ON storage.objects
    FOR DELETE USING (bucket_id = 'resources' AND auth.uid() = owner);

-- ============================================================
-- SEED DATA
-- ============================================================
INSERT INTO public.system_settings (key, value, description, category, is_public) VALUES
('site_name', 'CastroEduConnect', 'Platform name', 'general', true),
('site_tagline', 'Connecting Learners, Empowering Futures.', 'Platform tagline', 'general', true),
('primary_color', '#2563EB', 'Primary brand color', 'branding', true),
('secondary_color', '#4F46E5', 'Secondary brand color', 'branding', true),
('enable_registration', 'true', 'Allow new user registrations', 'security', false);

INSERT INTO public.grades (name, code, sort_order) VALUES
('Grade 1', 'G1', 1),
('Grade 2', 'G2', 2),
('Grade 3', 'G3', 3),
('Grade 4', 'G4', 4),
('Grade 5', 'G5', 5),
('Grade 6', 'G6', 6),
('Grade 7', 'G7', 7),
('Grade 8', 'G8', 8),
('Grade 9', 'G9', 9),
('Form 1', 'F1', 10),
('Form 2', 'F2', 11),
('Form 3', 'F3', 12),
('Form 4', 'F4', 13);

INSERT INTO public.subjects (name, code, description, grade_id, color) VALUES
('Mathematics', 'MATH-G1', 'Mathematics for Grade 1', (SELECT id FROM public.grades WHERE code = 'G1'), '#2563EB'),
('English', 'ENG-G1', 'English Language and Literature', (SELECT id FROM public.grades WHERE code = 'G1'), '#4F46E5'),
('Science', 'SCI-G1', 'Integrated Science', (SELECT id FROM public.grades WHERE code = 'G1'), '#10B981'),
('Kiswahili', 'KIS-G1', 'Kiswahili Language', (SELECT id FROM public.grades WHERE code = 'G1'), '#F59E0B'),
('Social Studies', 'SST-G1', 'Social Studies and Life Skills', (SELECT id FROM public.grades WHERE code = 'G1'), '#EF4444');

-- ============================================================
-- DONE. Next steps:
-- 1. In Supabase Dashboard > Authentication > Providers, make sure
--    "Confirm email" matches what you want (off is easier while testing).
-- 2. Register a user through register.html, then in the SQL editor run:
--      UPDATE public.profiles SET role = 'admin' WHERE email = 'you@example.com';
--    to promote your first account to admin.
-- 3. Register a teacher account, then in the Table Editor assign that
--    teacher's id to a subject's teacher_id so they can manage it.
-- ============================================================
