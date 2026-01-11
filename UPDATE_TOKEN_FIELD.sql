-- VISIO 360° Token Alanı Ekleme
-- Bu scripti Supabase SQL Editor'da çalıştırın

-- evaluation_assignments tablosuna token alanı ekle
ALTER TABLE evaluation_assignments 
ADD COLUMN IF NOT EXISTS token VARCHAR(50) UNIQUE;

-- Mevcut kayıtlara token oluştur
UPDATE evaluation_assignments 
SET token = substr(md5(random()::text), 1, 12)
WHERE token IS NULL;

-- Token index oluştur (performans için)
CREATE INDEX IF NOT EXISTS idx_assignments_token ON evaluation_assignments(token);

-- evaluation_responses tablosunu güncelle (eğer yoksa)
CREATE TABLE IF NOT EXISTS evaluation_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    assignment_id UUID REFERENCES evaluation_assignments(id) ON DELETE CASCADE,
    question_number INTEGER NOT NULL,
    category_code VARCHAR(10),
    selected_option INTEGER,
    reel_score INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS politikası (public erişim için - form.html kullanabilsin)
ALTER TABLE evaluation_assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE evaluation_responses ENABLE ROW LEVEL SECURITY;

-- Herkese okuma/yazma izni (anon key ile erişim)
DROP POLICY IF EXISTS "Allow public read assignments" ON evaluation_assignments;
CREATE POLICY "Allow public read assignments" ON evaluation_assignments FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow public update assignments" ON evaluation_assignments;
CREATE POLICY "Allow public update assignments" ON evaluation_assignments FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow public insert responses" ON evaluation_responses;
CREATE POLICY "Allow public insert responses" ON evaluation_responses FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow public read responses" ON evaluation_responses;
CREATE POLICY "Allow public read responses" ON evaluation_responses FOR SELECT USING (true);

SELECT 'Token alanı ve gerekli izinler eklendi!' as status;
