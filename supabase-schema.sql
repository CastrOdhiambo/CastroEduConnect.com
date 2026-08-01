-- CastroEduConnect - Complete Database Schema
-- Run this in your Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('admin', 'teacher', 'learner')),
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

-- Grades
CREATE TABLE public.grades (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    sort_order INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Classes
CREATE TABLE public.classes (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    grade_id UUID REFERENCES public.grades(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    teacher_id UUID REFERENCES public.profiles(id),
    room_number TEXT,
    capacity INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subjects
CREATE TABLE public.subjects (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    grade_id UUID REFERENCES public.grades(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.profiles(id),
    color TEXT DEFAULT '#2563EB',
    icon TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subject Enrollments
CREATE TABLE public.subject_enrollments (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'dropped', 'completed')),
    UNIQUE(subject_id, learner_id)
);

-- Assessments
CREATE TABLE public.assessments (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    grade_id UUID REFERENCES public.grades(id),
    class_id UUID REFERENCES public.classes(id),
    assessment_type TEXT NOT NULL CHECK (assessment_type IN ('assignment', 'quiz', 'cat', 'exam')),
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
    is_published BOOLEAN DEFAULT false,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Question Bank
CREATE TABLE public.question_bank (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
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

-- Questions
CREATE TABLE public.questions (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE,
    question_bank_id UUID REFERENCES public.question_bank(id),
    question_text TEXT NOT NULL,
    question_type TEXT NOT NULL CHECK (question_type IN ('multiple_choice', 'true_false', 'essay', 'short_answer', 'matching', 'fill_blank')),
    marks INTEGER DEFAULT 1,
    correct_answer TEXT,
    explanation TEXT,
    hint TEXT,
    image_url TEXT,
    sort_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Choices
CREATE TABLE public.choices (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    choice_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT false,
    sort_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Matching Pairs
CREATE TABLE public.matching_pairs (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    question_id UUID REFERENCES public.questions(id) ON DELETE CASCADE,
    left_text TEXT NOT NULL,
    right_text TEXT NOT NULL,
    sort_order INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Submissions
CREATE TABLE public.submissions (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    assessment_id UUID REFERENCES public.assessments(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    submitted_at TIMESTAMP WITH TIME ZONE,
    time_taken INTEGER,
    status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'submitted', 'grading', 'graded', 'returned')),
    total_score DECIMAL(5,2),
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

-- Answers
CREATE TABLE public.answers (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
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

-- Resources
CREATE TABLE public.resources (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    subject_id UUID REFERENCES public.subjects(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    file_url TEXT NOT NULL,
    file_type TEXT CHECK (file_type IN ('pdf', 'word', 'powerpoint', 'image', 'video', 'zip', 'other')),
    file_size BIGINT,
    is_published BOOLEAN DEFAULT true,
    download_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Resource Bookmarks
CREATE TABLE public.resource_bookmarks (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    resource_id UUID REFERENCES public.resources(id) ON DELETE CASCADE,
    learner_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(resource_id, learner_id)
);

-- Announcements
CREATE TABLE public.announcements (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    target_role TEXT CHECK (target_role IN ('all', 'admin', 'teacher', 'learner')),
    target_grade_id UUID REFERENCES public.grades(id),
    target_class_id UUID REFERENCES public.classes(id),
    target_subject_id UUID REFERENCES public.subjects(id),
    is_pinned BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications
CREATE TABLE public.notifications (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('assignment', 'exam', 'grade', 'feedback', 'announcement', 'deadline', 'system')),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    link TEXT,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Logs
CREATE TABLE public.activity_logs (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    details JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit Logs
CREATE TABLE public.audit_logs (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    admin_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    target_user_id UUID REFERENCES public.profiles(id),
    details JSONB,
    ip_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- System Settings
CREATE TABLE public.system_settings (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
    key TEXT UNIQUE NOT NULL,
    value TEXT,
    description TEXT,
    category TEXT,
    is_public BOOLEAN DEFAULT false,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics Daily
CREATE TABLE public.analytics_daily (
    id UUID DEFAULT uuid-ossp() PRIMARY KEY,
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

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grades ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subject_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_bank ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.choices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matching_pairs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resource_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_daily ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view all profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Teachers can manage subjects" ON public.subjects FOR ALL USING (auth.uid() = teacher_id);
CREATE POLICY "Learners can view subjects" ON public.subjects FOR SELECT USING (true);
CREATE POLICY "Teachers can manage assessments" ON public.assessments FOR ALL USING (auth.uid() = teacher_id);
CREATE POLICY "Learners can view assessments" ON public.assessments FOR SELECT USING (true);
CREATE POLICY "Learners can manage own submissions" ON public.submissions FOR ALL USING (auth.uid() = learner_id);
CREATE POLICY "Teachers can view submissions" ON public.submissions FOR SELECT USING (auth.uid() IN (SELECT teacher_id FROM public.assessments WHERE id = assessment_id));
CREATE POLICY "Users can manage own notifications" ON public.notifications FOR ALL USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_submissions_assessment_id ON public.submissions(assessment_id);
CREATE INDEX idx_submissions_learner_id ON public.submissions(learner_id);
CREATE INDEX idx_answers_submission_id ON public.answers(submission_id);
CREATE INDEX idx_answers_question_id ON public.answers(question_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_activity_logs_user_id ON public.activity_logs(user_id);
CREATE INDEX idx_assessments_subject_id ON public.assessments(subject_id);
CREATE INDEX idx_assessments_teacher_id ON public.assessments(teacher_id);
CREATE INDEX idx_questions_assessment_id ON public.questions(assessment_id);
CREATE INDEX idx_resources_subject_id ON public.resources(subject_id);
CREATE INDEX idx_announcements_author_id ON public.announcements(author_id);

-- Update updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_assessments_updated_at BEFORE UPDATE ON public.assessments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_submissions_updated_at BEFORE UPDATE ON public.submissions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_answers_updated_at BEFORE UPDATE ON public.answers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_resources_updated_at BEFORE UPDATE ON public.resources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON public.announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, first_name, last_name, role)
    VALUES (NEW.id, NEW.email, '', '', 'learner');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Seed data
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
('Mathematics', 'MATH', 'Mathematics for all grades', (SELECT id FROM public.grades WHERE code = 'G1'), '#2563EB'),
('English', 'ENG', 'English Language and Literature', (SELECT id FROM public.grades WHERE code = 'G1'), '#4F46E5'),
('Science', 'SCI', 'Integrated Science', (SELECT id FROM public.grades WHERE code = 'G1'), '#10B981'),
('Kiswahili', 'KIS', 'Kiswahili Language', (SELECT id FROM public.grades WHERE code = 'G1'), '#F59E0B'),
('Social Studies', 'SST', 'Social Studies and Life Skills', (SELECT id FROM public.grades WHERE code = 'G1'), '#EF4444');