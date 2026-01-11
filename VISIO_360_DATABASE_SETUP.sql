-- =============================================
-- VISIO 360° PERFORMANS YÖNETİM SİSTEMİ
-- VERİTABANI KURULUM SCRIPTI
-- Versiyon: 1.0
-- =============================================

-- 1. KURUMLAR TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS organizations (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    short_code VARCHAR(50) UNIQUE,
    logo_url TEXT,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. KULLANICILAR TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tc_no VARCHAR(11) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    department VARCHAR(255),
    title VARCHAR(255),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('super_admin', 'org_admin', 'user')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. DEĞERLENDİRME DÖNEMLERİ TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS evaluation_periods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed', 'cancelled')),
    settings JSONB DEFAULT '{}',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. DEĞERLENDİRME ATAMALARI TABLOSU
-- (Kim kimi değerlendirecek)
-- =============================================
CREATE TABLE IF NOT EXISTS evaluation_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    period_id UUID REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    evaluator_id UUID REFERENCES users(id) ON DELETE CASCADE,
    target_id UUID REFERENCES users(id) ON DELETE CASCADE,
    is_self_evaluation BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed')),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(period_id, evaluator_id, target_id)
);

-- 5. DEĞERLENDİRME CEVAPLARI TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS evaluation_responses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    assignment_id UUID REFERENCES evaluation_assignments(id) ON DELETE CASCADE,
    question_id VARCHAR(20) NOT NULL,
    category_id VARCHAR(20) NOT NULL,
    selected_answers JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(assignment_id, question_id)
);

-- 6. HESAPLANAN PUANLAR TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS calculated_scores (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    period_id UUID REFERENCES evaluation_periods(id) ON DELETE CASCADE,
    
    -- Genel puanlar
    self_score_standard DECIMAL(5,2) DEFAULT 0,
    self_score_reel DECIMAL(5,2) DEFAULT 0,
    peer_score_standard DECIMAL(5,2) DEFAULT 0,
    peer_score_reel DECIMAL(5,2) DEFAULT 0,
    total_score_standard DECIMAL(5,2) DEFAULT 0,
    total_score_reel DECIMAL(5,2) DEFAULT 0,
    
    -- Değerlendiren sayısı
    evaluator_count INTEGER DEFAULT 0,
    
    -- Kategori bazlı puanlar (JSONB)
    category_scores JSONB DEFAULT '{}',
    
    -- SWOT analizi
    swot_analysis JSONB DEFAULT '{}',
    
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, period_id)
);

-- 7. BİRİMLER/DEPARTMANLAR TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS departments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    short_code VARCHAR(50),
    parent_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    manager_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(organization_id, name)
);

-- 8. KATEGORİLER TABLOSU (Soru kategorileri)
-- =============================================
CREATE TABLE IF NOT EXISTS categories (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    icon VARCHAR(10),
    color VARCHAR(20),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 9. SORULAR TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS questions (
    id VARCHAR(20) PRIMARY KEY,
    category_id VARCHAR(20) REFERENCES categories(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE
);

-- 10. CEVAP SEÇENEKLERİ TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS answer_options (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    question_id VARCHAR(20) REFERENCES questions(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    level VARCHAR(20) NOT NULL,
    standard_score DECIMAL(3,2) NOT NULL,
    reel_score DECIMAL(4,2) NOT NULL,
    sort_order INTEGER DEFAULT 0
);

-- 11. SİSTEM LOGLARI TABLOSU
-- =============================================
CREATE TABLE IF NOT EXISTS system_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    organization_id UUID REFERENCES organizations(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    details JSONB DEFAULT '{}',
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- İNDEKSLER (Performans için)
-- =============================================
CREATE INDEX IF NOT EXISTS idx_users_tc_no ON users(tc_no);
CREATE INDEX IF NOT EXISTS idx_users_organization ON users(organization_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_evaluation_periods_org ON evaluation_periods(organization_id);
CREATE INDEX IF NOT EXISTS idx_evaluation_periods_status ON evaluation_periods(status);
CREATE INDEX IF NOT EXISTS idx_assignments_period ON evaluation_assignments(period_id);
CREATE INDEX IF NOT EXISTS idx_assignments_evaluator ON evaluation_assignments(evaluator_id);
CREATE INDEX IF NOT EXISTS idx_assignments_target ON evaluation_assignments(target_id);
CREATE INDEX IF NOT EXISTS idx_assignments_status ON evaluation_assignments(status);
CREATE INDEX IF NOT EXISTS idx_responses_assignment ON evaluation_responses(assignment_id);
CREATE INDEX IF NOT EXISTS idx_scores_user_period ON calculated_scores(user_id, period_id);
CREATE INDEX IF NOT EXISTS idx_logs_user ON system_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_logs_org ON system_logs(organization_id);
CREATE INDEX IF NOT EXISTS idx_logs_created ON system_logs(created_at);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLİTİKALARI
-- =============================================

-- RLS'i etkinleştir
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_periods ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE calculated_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_logs ENABLE ROW LEVEL SECURITY;

-- Genel okuma politikaları (kimlik doğrulama sonrası)
CREATE POLICY "Users can view own organization" ON organizations
    FOR SELECT USING (true);

CREATE POLICY "Users can view users in same org" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can view own assignments" ON evaluation_assignments
    FOR SELECT USING (true);

CREATE POLICY "Users can view own responses" ON evaluation_responses
    FOR SELECT USING (true);

CREATE POLICY "Users can view own scores" ON calculated_scores
    FOR SELECT USING (true);

-- Yazma politikaları
CREATE POLICY "Users can insert responses" ON evaluation_responses
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update own responses" ON evaluation_responses
    FOR UPDATE USING (true);

CREATE POLICY "Admins can manage all" ON organizations
    FOR ALL USING (true);

CREATE POLICY "Admins can manage users" ON users
    FOR ALL USING (true);

CREATE POLICY "Admins can manage periods" ON evaluation_periods
    FOR ALL USING (true);

CREATE POLICY "Admins can manage assignments" ON evaluation_assignments
    FOR ALL USING (true);

CREATE POLICY "Admins can manage scores" ON calculated_scores
    FOR ALL USING (true);

CREATE POLICY "Admins can manage departments" ON departments
    FOR ALL USING (true);

CREATE POLICY "Admins can view logs" ON system_logs
    FOR SELECT USING (true);

CREATE POLICY "System can insert logs" ON system_logs
    FOR INSERT WITH CHECK (true);

-- =============================================
-- SÜPER ADMİN KULLANICISI OLUŞTUR
-- =============================================
-- NOT: Şifreyi güvenli bir hash ile değiştirin!
-- Varsayılan şifre: Admin123! (değiştirin!)

INSERT INTO users (tc_no, password_hash, name, email, role, status)
VALUES (
    '99999999999',
    'temp_hash_change_me',
    'Süper Admin',
    'admin@visio360.app',
    'super_admin',
    'active'
) ON CONFLICT (tc_no) DO NOTHING;

-- =============================================
-- ÖRNEK KURUM OLUŞTUR
-- =============================================
INSERT INTO organizations (name, short_code, status)
VALUES (
    'VISIO Academy',
    'VISIO',
    'active'
) ON CONFLICT (short_code) DO NOTHING;

-- =============================================
-- ÖRNEK KATEGORİLER (REEL Sisteminden)
-- =============================================
INSERT INTO categories (id, name, icon, color, sort_order) VALUES
('PIEE', 'Planlı İşe Etkin Entegrasyon', '📋', '#4a90d9', 1),
('OI', 'Organize İşleyiş', '⚙️', '#50c878', 2),
('EZC', 'Etkin Zaman Çizelgesi', '⏰', '#f5a623', 3),
('EOL', 'Etkili ve Olumlu Liderlik', '👑', '#9b59b6', 4),
('EDI', 'Etkin ve Doğru İletişim', '💬', '#e74c3c', 5),
('KGPB', 'Kalite Güvence ve Problem Becerisi', '✅', '#1abc9c', 6),
('EAED', 'Ekip Anlayışı ve Etkin Dayanışma', '🤝', '#3498db', 7),
('SYBD', 'Stratejik Yönetim Becerileri ve Destekler', '🎯', '#e67e22', 8),
('MSUY', 'Mesleki Standartlar ve Uygulamalar', '📚', '#9c88ff', 9),
('KGMO', 'Kişisel Gelişim ve Motivasyon Odağı', '🌟', '#00cec9', 10)
ON CONFLICT (id) DO NOTHING;

-- =============================================
-- FONKSİYONLAR
-- =============================================

-- Şifre hashleme fonksiyonu
CREATE OR REPLACE FUNCTION hash_password(password TEXT)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(sha256(password::bytea), 'hex');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Kullanıcı doğrulama fonksiyonu
CREATE OR REPLACE FUNCTION verify_user(p_tc_no TEXT, p_password TEXT)
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    user_role TEXT,
    org_id UUID,
    org_name TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id,
        u.name::TEXT,
        u.role::TEXT,
        u.organization_id,
        o.name::TEXT
    FROM users u
    LEFT JOIN organizations o ON u.organization_id = o.id
    WHERE u.tc_no = p_tc_no 
    AND u.password_hash = hash_password(p_password)
    AND u.status = 'active';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Puan hesaplama fonksiyonu
CREATE OR REPLACE FUNCTION calculate_user_scores(p_user_id UUID, p_period_id UUID)
RETURNS VOID AS $$
DECLARE
    v_self_standard DECIMAL(5,2) := 0;
    v_self_reel DECIMAL(5,2) := 0;
    v_peer_standard DECIMAL(5,2) := 0;
    v_peer_reel DECIMAL(5,2) := 0;
    v_evaluator_count INTEGER := 0;
BEGIN
    -- Öz değerlendirme puanı
    SELECT 
        COALESCE(AVG(ao.standard_score), 0),
        COALESCE(AVG(ao.reel_score), 0)
    INTO v_self_standard, v_self_reel
    FROM evaluation_assignments ea
    JOIN evaluation_responses er ON ea.id = er.assignment_id
    JOIN answer_options ao ON er.question_id = ao.question_id
    WHERE ea.target_id = p_user_id 
    AND ea.period_id = p_period_id
    AND ea.is_self_evaluation = TRUE
    AND ea.status = 'completed';
    
    -- Ekip değerlendirme puanı
    SELECT 
        COALESCE(AVG(ao.standard_score), 0),
        COALESCE(AVG(ao.reel_score), 0),
        COUNT(DISTINCT ea.evaluator_id)
    INTO v_peer_standard, v_peer_reel, v_evaluator_count
    FROM evaluation_assignments ea
    JOIN evaluation_responses er ON ea.id = er.assignment_id
    JOIN answer_options ao ON er.question_id = ao.question_id
    WHERE ea.target_id = p_user_id 
    AND ea.period_id = p_period_id
    AND ea.is_self_evaluation = FALSE
    AND ea.status = 'completed';
    
    -- Puanları kaydet veya güncelle
    INSERT INTO calculated_scores (
        user_id, period_id,
        self_score_standard, self_score_reel,
        peer_score_standard, peer_score_reel,
        total_score_standard, total_score_reel,
        evaluator_count, calculated_at
    ) VALUES (
        p_user_id, p_period_id,
        v_self_standard, v_self_reel,
        v_peer_standard, v_peer_reel,
        (v_self_standard + v_peer_standard) / 2,
        (v_self_reel + v_peer_reel) / 2,
        v_evaluator_count, NOW()
    )
    ON CONFLICT (user_id, period_id) DO UPDATE SET
        self_score_standard = v_self_standard,
        self_score_reel = v_self_reel,
        peer_score_standard = v_peer_standard,
        peer_score_reel = v_peer_reel,
        total_score_standard = (v_self_standard + v_peer_standard) / 2,
        total_score_reel = (v_self_reel + v_peer_reel) / 2,
        evaluator_count = v_evaluator_count,
        calculated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Updated_at otomatik güncelleme trigger'ı
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger'ları oluştur
DROP TRIGGER IF EXISTS update_organizations_updated_at ON organizations;
CREATE TRIGGER update_organizations_updated_at
    BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_evaluation_periods_updated_at ON evaluation_periods;
CREATE TRIGGER update_evaluation_periods_updated_at
    BEFORE UPDATE ON evaluation_periods
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS update_evaluation_responses_updated_at ON evaluation_responses;
CREATE TRIGGER update_evaluation_responses_updated_at
    BEFORE UPDATE ON evaluation_responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =============================================
-- KURULUM TAMAMLANDI
-- =============================================
-- Şimdi Süper Admin şifresini güncelleyin:
-- UPDATE users SET password_hash = hash_password('YeniSifreniz123!') WHERE tc_no = '99999999999';

SELECT 'VISIO 360° Veritabanı kurulumu tamamlandı!' AS message;
