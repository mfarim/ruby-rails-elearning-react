import api from '../api/client';
import type { ApiResponse, Subject } from '../types';

export interface SubjectInput {
  name: string;
  code: string;
  description?: string;
  credits: number;
  teacherId?: number | null;
}

export const subjectService = {
  async getAll(): Promise<Subject[]> {
    const res = await api.get<ApiResponse<Subject[]>>('/subjects');
    return res.data.data;
  },

  async getById(id: number): Promise<Subject> {
    const res = await api.get<ApiResponse<Subject>>(`/subjects/${id}`);
    return res.data.data;
  },

  async create(data: SubjectInput): Promise<Subject> {
    const res = await api.post<ApiResponse<Subject>>('/subjects', data);
    return res.data.data;
  },

  async update(id: number, data: SubjectInput): Promise<Subject> {
    const res = await api.put<ApiResponse<Subject>>(`/subjects/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/subjects/${id}`);
  },
};
