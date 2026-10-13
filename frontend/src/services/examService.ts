import api from '../api/client';
import type { ApiResponse, Exam, ExamMonitorItem, ExamStartResponse, Question } from '../types';

export const examService = {
  async getAll(): Promise<Exam[]> {
    const res = await api.get<ApiResponse<Exam[]>>('/exams');
    return res.data.data;
  },

  async getById(id: number): Promise<Exam> {
    const res = await api.get<ApiResponse<Exam>>(`/exams/${id}`);
    return res.data.data;
  },

  async create(data: Partial<Exam>): Promise<Exam> {
    const res = await api.post<ApiResponse<Exam>>('/exams', data);
    return res.data.data;
  },

  async update(id: number, data: Partial<Exam>): Promise<Exam> {
    const res = await api.put<ApiResponse<Exam>>(`/exams/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/exams/${id}`);
  },

  async updateStatus(id: number, status: string): Promise<Exam> {
    const res = await api.patch<ApiResponse<Exam>>(`/exams/${id}/status`, { status });
    return res.data.data;
  },

  async getQuestions(id: number): Promise<Question[]> {
    const res = await api.get<ApiResponse<Question[]>>(`/exams/${id}/questions`);
    return res.data.data;
  },

  async createQuestion(examId: number, data: Partial<Question>): Promise<Question> {
    const res = await api.post<ApiResponse<Question>>(`/exams/${examId}/questions`, data);
    return res.data.data;
  },

  async updateQuestion(examId: number, questionId: number, data: Partial<Question>): Promise<Question> {
    const res = await api.put<ApiResponse<Question>>(`/exams/${examId}/questions/${questionId}`, data);
    return res.data.data;
  },

  async deleteQuestion(examId: number, questionId: number): Promise<void> {
    await api.delete(`/exams/${examId}/questions/${questionId}`);
  },

  async importQuestionsExcel(examId: number, file: File): Promise<{ count: number }> {
    const formData = new FormData();
    formData.append('file', file);
    const res = await api.post<ApiResponse<{ count: number }>>(`/exams/${examId}/questions/import-excel`, formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return res.data.data;
  },

  // CBT Exam Runner
  async startExam(examId: number): Promise<ExamStartResponse> {
    const res = await api.post<ApiResponse<ExamStartResponse>>(`/exams/${examId}/start`);
    return res.data.data;
  },

  async saveAnswer(attemptId: number, questionId: number, answer: string): Promise<void> {
    await api.post(`/exams/attempts/${attemptId}/answer`, { questionId, answer });
  },

  async recordViolation(attemptId: number): Promise<{ violations: number }> {
    const res = await api.post<ApiResponse<{ violations: number }>>(`/exams/attempts/${attemptId}/violation`);
    return res.data.data;
  },

  async submitExam(attemptId: number): Promise<{
    score: number;
    passed: boolean;
    status: string;
    totalQuestions: number;
    answeredCount: number;
  }> {
    const res = await api.post<ApiResponse<{
      score: number;
      passed: boolean;
      status: string;
      totalQuestions: number;
      answeredCount: number;
    }>>(`/exams/attempts/${attemptId}/submit`);
    return res.data.data;
  },

  async gradeEssay(attemptId: number, answerId: number, pointsAwarded: number, isCorrect: boolean): Promise<void> {
    await api.post(`/exams/attempts/${attemptId}/answers/${answerId}/grade-essay`, {
      pointsAwarded,
      isCorrect,
    });
  },

  async getMonitorData(examId: number): Promise<ExamMonitorItem[]> {
    const res = await api.get<ApiResponse<ExamMonitorItem[]>>(`/exams/${examId}/monitor`);
    return res.data.data;
  },
};
