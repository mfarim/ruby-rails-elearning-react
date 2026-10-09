puts "Seeding demo records for Ruby on Rails E-Learning platform..."

# Clean up existing records in reverse dependency order
ExamAnswer.destroy_all
ExamAttempt.destroy_all
Question.destroy_all
Examination.destroy_all
AssignmentDiscussion.destroy_all
AssignmentSubmission.destroy_all
Assignment.destroy_all
MaterialView.destroy_all
LearningMaterial.destroy_all
Announcement.destroy_all
Student.destroy_all
Classroom.destroy_all
Subject.destroy_all
Teacher.destroy_all
User.destroy_all

# 1. Admin User
admin = User.create!(
  name: "Administrator System",
  email: "admin@elearning.test",
  password: "password123",
  role: "ROLE_ADMIN",
  active: true
)
puts "  Created Admin: #{admin.email}"

# 2. Teachers
user_teacher1 = User.create!(
  name: "Budi Santoso, M.Pd.",
  email: "teacher@elearning.test",
  password: "password123",
  role: "ROLE_TEACHER",
  active: true
)
teacher1 = Teacher.create!(
  user: user_teacher1,
  nip: "198501152010011002",
  name: user_teacher1.name,
  email: user_teacher1.email,
  phone: "081234567890",
  address: "Jl. Pendidikan No. 45, Bandar Lampung",
  active: true
)

user_teacher2 = User.create!(
  name: "Siti Nurhaliza, S.Pd.",
  email: "teacher2@elearning.test",
  password: "password123",
  role: "ROLE_TEACHER",
  active: true
)
teacher2 = Teacher.create!(
  user: user_teacher2,
  nip: "199002202015022001",
  name: user_teacher2.name,
  email: user_teacher2.email,
  phone: "081234567891",
  address: "Jl. Dahlia No. 12, Bandar Lampung",
  active: true
)
puts "  Created Teachers: #{teacher1.name}, #{teacher2.name}"

# 3. Classrooms
c1 = Classroom.create!(
  name: "10-MIPA-1",
  level: 10,
  capacity: 36,
  academic_year: "2025/2026",
  homeroom_teacher: teacher1
)
c2 = Classroom.create!(
  name: "10-MIPA-2",
  level: 10,
  capacity: 36,
  academic_year: "2025/2026",
  homeroom_teacher: teacher2
)
c3 = Classroom.create!(
  name: "11-MIPA-1",
  level: 11,
  capacity: 36,
  academic_year: "2025/2026"
)
puts "  Created Classrooms: #{c1.name}, #{c2.name}, #{c3.name}"

# 4. Students
user_student1 = User.create!(
  name: "Ahmad Pratama",
  email: "student@elearning.test",
  password: "password123",
  role: "ROLE_STUDENT",
  active: true
)
student1 = Student.create!(
  user: user_student1,
  classroom: c1,
  nis: "202510001",
  nisn: "0071234567",
  name: user_student1.name,
  email: user_student1.email,
  phone: "089876543210",
  gender: "M",
  birth_date: Date.parse("2008-05-14"),
  address: "Jl. Melati No. 8, Bandar Lampung",
  active: true
)

user_student2 = User.create!(
  name: "Putri Maharani",
  email: "student2@elearning.test",
  password: "password123",
  role: "ROLE_STUDENT",
  active: true
)
student2 = Student.create!(
  user: user_student2,
  classroom: c1,
  nis: "202510002",
  nisn: "0071234568",
  name: user_student2.name,
  email: user_student2.email,
  phone: "089876543211",
  gender: "F",
  birth_date: Date.parse("2008-08-22"),
  address: "Jl. Mawar No. 19, Bandar Lampung",
  active: true
)

user_student3 = User.create!(
  name: "Rizky Ramadhan",
  email: "student3@elearning.test",
  password: "password123",
  role: "ROLE_STUDENT",
  active: true
)
student3 = Student.create!(
  user: user_student3,
  classroom: c2,
  nis: "202510003",
  nisn: "0071234569",
  name: user_student3.name,
  email: user_student3.email,
  gender: "M",
  birth_date: Date.parse("2008-01-10"),
  active: true
)
puts "  Created Students: #{student1.name}, #{student2.name}, #{student3.name}"

# 5. Subjects
s1 = Subject.create!(
  name: "Pemrograman Web & Basis Data",
  code: "WEB-10",
  description: "Dasar-dasar HTML5, CSS modern, JavaScript ES6+, arsitektur REST API, dan basis data relasional.",
  teacher: teacher1,
  credits: 4
)
s2 = Subject.create!(
  name: "Matematika Wajib",
  code: "MTK-10",
  description: "Aljabar, fungsi kuadrat, trigonometri, dan kalkulus diferensial dasar.",
  teacher: teacher1,
  credits: 4
)
s3 = Subject.create!(
  name: "Bahasa Inggris Akademik",
  code: "ENG-10",
  description: "Academic writing, listening comprehension, dan technical reading skills.",
  teacher: teacher2,
  credits: 3
)
puts "  Created Subjects: #{s1.name}, #{s2.name}, #{s3.name}"

# 6. Announcements
Announcement.create!(
  title: "Jadwal Ujian Tengah Semester (UTS) Ganjil 2025/2026",
  content: "Ujian Tengah Semester akan dimulai pada tanggal 20 Oktober 2025. Seluruh siswa diharapkan mencetak kartu peserta ujian masing-masing.",
  target: "all",
  published: true
)
Announcement.create!(
  title: "Pengunggahan RPP & Bank Soal CBT Semester Ganjil",
  content: "Batas akhir sinkronisasi bank soal CBT dan silabus materi pembelajaran adalah hari Jumat pukul 17:00 WIB.",
  target: "teacher",
  published: true
)
Announcement.create!(
  title: "Sosialisasi Engine Anti-Cheat & Lock Screen CBT",
  content: "Aplikasi ujian CBT kini dilengkapi telemetry anti-cheat otomatis. Pergantian tab dan keluar dari mode layar penuh akan dicatat sebagai pelanggaran.",
  target: "student",
  published: true
)
puts "  Created Announcements."

# 7. Learning Materials
m1 = LearningMaterial.create!(
  teacher: teacher1,
  subject: s1,
  classroom: c1,
  title: "Pengenalan Arsitektur RESTful API & Ruby on Rails 8",
  description: "Konsep dasar REST, status code HTTP, controller, Active Record, dan routing modern di Rails 8.",
  material_type: "document",
  content: "REST (Representational State Transfer) adalah standar arsitektur komunikasi web service tanpa status (stateless) yang menggunakan protokol HTTP secara murni.",
  published: true,
  total_views: 12
)
m2 = LearningMaterial.create!(
  teacher: teacher1,
  subject: s1,
  classroom: c1,
  title: "Tutorial Lengkap React 19, TypeScript & Tailwind CSS v4",
  description: "Panduan membangun single page application modern dengan React 19 hooks, Vite, dan Tailwind CSS v4 styling.",
  material_type: "video",
  content: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  published: true,
  total_views: 24
)
MaterialView.create!(learning_material: m1, student: student1, viewed_at: 1.day.ago)
MaterialView.create!(learning_material: m1, student: student2, viewed_at: 2.days.ago)
MaterialView.create!(learning_material: m2, student: student1, viewed_at: 12.hours.ago)
puts "  Created Learning Materials & Views."

# 8. Assignments
a1 = Assignment.create!(
  teacher: teacher1,
  subject: s1,
  classroom: c1,
  title: "Tugas 1: Membuat CRUD REST API dengan Rails & React",
  description: "Bangun endpoint RESTful untuk entitas Produk dan hubungkan dengan form antarmuka React.",
  instructions: "1. Tulis controller Rails untuk GET, POST, PUT, DELETE.\n2. Gunakan Axios interceptor untuk Bearer token auth.\n3. Kumpulkan URL repo git dan tangkapan layar.",
  max_score: 100,
  due_date: 3.days.from_now,
  allow_late_submission: true,
  status: "published"
)
sub1 = AssignmentSubmission.create!(
  assignment: a1,
  student: student1,
  notes: "Tugas telah selesai dikerjakan sesuai spesifikasi instruksi.",
  score: 95.0,
  feedback: "Pekerjaan sangat rapi, validasi data lengkap, dan kode terstruktur dengan baik.",
  status: "graded",
  submitted_at: 1.day.ago,
  graded_at: 12.hours.ago
)
disc1 = AssignmentDiscussion.create!(
  assignment: a1,
  user: user_student1,
  message: "Pak, apakah untuk pengujian API diperbolehkan menggunakan Postman?"
)
AssignmentDiscussion.create!(
  assignment: a1,
  user: user_teacher1,
  parent: disc1,
  message: "Ya tentu, silakan ekspor koleksi Postman atau sertakan file curl-nya."
)
puts "  Created Assignments, Submissions & Discussions."

# 9. Examinations & Questions
exam1 = Examination.create!(
  teacher: teacher1,
  subject: s1,
  classroom: c1,
  title: "Kuis 1: Dasar Logika Pemrograman Web & Arsitektur API",
  description: "Kuis kompetensi awal mencakup konsep HTTP methods, JSON serialization, dan MVC pattern.",
  exam_type: "quiz",
  duration_minutes: 30,
  passing_score: 75.0,
  start_at: 2.days.ago,
  end_at: 2.days.from_now,
  shuffle_questions: false,
  shuffle_options: false,
  show_result: true,
  allow_retry: true,
  status: "published"
)

q1 = Question.create!(
  examination: exam1,
  question_text: "Manakah method HTTP berikut yang bersifat idempoten dan digunakan untuk memperbarui seluruh data entitas?",
  question_type: "multiple_choice",
  options: ["POST", "PUT", "PATCH", "GET"],
  points: 25,
  difficulty: "medium",
  correct_answer: "1", # Index 1 = PUT
  explanation: "HTTP PUT bersifat idempoten karena request berulang menghasilkan state yang sama persis."
)

q2 = Question.create!(
  examination: exam1,
  question_text: "Active Record pada framework Ruby on Rails mengimplementasikan pola arsitektur Object-Relational Mapping (ORM).",
  question_type: "true_false",
  options: ["Benar", "Salah"],
  points: 25,
  difficulty: "easy",
  correct_answer: "0", # Index 0 = Benar
  explanation: "Active Record adalah implementasi langsung dari pola ORM buatan Martin Fowler."
)

q3 = Question.create!(
  examination: exam1,
  question_text: "Status code HTTP 401 Unauthorized menandakan bahwa permintaan klien memerlukan kredensial otentikasi yang valid.",
  question_type: "true_false",
  options: ["Benar", "Salah"],
  points: 25,
  difficulty: "easy",
  correct_answer: "0",
  explanation: "401 mengindikasikan otentikasi gagal atau belum disediakan kredensial login."
)

q4 = Question.create!(
  examination: exam1,
  question_text: "Jelaskan perbedaan mendasar antara stateless JWT authentication dengan stateful session-based authentication!",
  question_type: "essay",
  options: [],
  points: 25,
  difficulty: "hard",
  correct_answer: "",
  explanation: "Stateless JWT menyimpan data klaim dan tanda tangan kriptografis pada token di klien tanpa penyimpanan state server."
)

# Demo Attempt for student1
att1 = ExamAttempt.create!(
  examination: exam1,
  student: student1,
  status: "completed",
  score: 90.0,
  passed: true,
  violations_count: 0,
  started_at: 1.day.ago,
  finished_at: 1.day.ago + 20.minutes,
  remaining_seconds: 0
)

ExamAnswer.create!(exam_attempt: att1, question: q1, student_answer: "1", is_correct: true, points_awarded: 25.0, graded_at: Time.current)
ExamAnswer.create!(exam_attempt: att1, question: q2, student_answer: "0", is_correct: true, points_awarded: 25.0, graded_at: Time.current)
ExamAnswer.create!(exam_attempt: att1, question: q3, student_answer: "0", is_correct: true, points_awarded: 25.0, graded_at: Time.current)
ExamAnswer.create!(exam_attempt: att1, question: q4, student_answer: "JWT tidak memerlukan database session di server karena payload ditandatangani dengan secret key.", is_correct: true, points_awarded: 15.0, graded_at: Time.current)

puts "  Created Examinations, Questions, Attempts & Answers."
puts "Demo seeding completed successfully! All accounts and relations ready."
