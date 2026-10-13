import api from '../api/client';
import type { ApiResponse, Classroom } from '../types';

export interface ClassroomInput {
  name: string;
  level: number;
  capacity: number;
  academicYear: string;
  homeroomTeacherId?: number | null;
}

export const classroomService = {
  async getAll(): Promise<Classroom[]> {
    const res = await api.get<ApiResponse<Classroom[]>>('/classrooms');
    return res.data.data;
  },

  async getById(id: number): Promise<Classroom> {
    const res = await api.get<ApiResponse<Classroom>>(`/classrooms/${id}`);
    return res.data.data;
  },

  async create(data: ClassroomInput): Promise<Classroom> {
    const res = await api.post<ApiResponse<Classroom>>('/classrooms', data);
    return res.data.data;
  },

  async update(id: number, data: ClassroomInput): Promise<Classroom> {
    const res = await api.put<ApiResponse<Classroom>>(`/classrooms/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/classrooms/${id}`);
  },
};
