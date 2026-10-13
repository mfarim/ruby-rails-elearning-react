import api from '../api/client';
import type { ApiResponse, Student, StudentExamCard } from '../types';

export interface StudentInput {
  name: string;
  email: string;
  nis: string;
  nisn?: string;
  gender: 'M' | 'F';
  classroomId?: number | null;
  phone?: string;
  address?: string;
  password?: string;
}

export const studentService = {
  async getAll(): Promise<Student[]> {
    const res = await api.get<ApiResponse<Student[]>>('/students');
    return res.data.data;
  },

  async getById(id: number): Promise<Student> {
    const res = await api.get<ApiResponse<Student>>(`/students/${id}`);
    return res.data.data;
  },

  async create(data: StudentInput): Promise<Student> {
    const res = await api.post<ApiResponse<Student>>('/students', data);
    return res.data.data;
  },

  async update(id: number, data: Partial<StudentInput>): Promise<Student> {
    const res = await api.put<ApiResponse<Student>>(`/students/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/students/${id}`);
  },

  async getExamCards(): Promise<StudentExamCard[]> {
    const res = await api.get<ApiResponse<StudentExamCard[]>>('/students/exam-cards');
    return res.data.data;
  },

  async importExcel(file: File): Promise<{ count: number }> {
    const formData = new FormData();
    formData.append('file', file);
    const res = await api.post<ApiResponse<{ count: number }>>('/students/import-excel', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    return res.data.data;
  },
};
