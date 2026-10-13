import api from '../api/client';
import type { ApiResponse, Teacher } from '../types';

export interface TeacherInput {
  name: string;
  email: string;
  nip: string;
  phone?: string;
  address?: string;
  password?: string;
}

export const teacherService = {
  async getAll(): Promise<Teacher[]> {
    const res = await api.get<ApiResponse<Teacher[]>>('/teachers');
    return res.data.data;
  },

  async getById(id: number): Promise<Teacher> {
    const res = await api.get<ApiResponse<Teacher>>(`/teachers/${id}`);
    return res.data.data;
  },

  async create(data: TeacherInput): Promise<Teacher> {
    const res = await api.post<ApiResponse<Teacher>>('/teachers', data);
    return res.data.data;
  },

  async update(id: number, data: Partial<TeacherInput>): Promise<Teacher> {
    const res = await api.put<ApiResponse<Teacher>>(`/teachers/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/teachers/${id}`);
  },
};
