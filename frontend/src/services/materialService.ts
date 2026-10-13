import api from '../api/client';
import type { ApiResponse, LearningMaterial } from '../types';

export const materialService = {
  async getAll(): Promise<LearningMaterial[]> {
    const res = await api.get<ApiResponse<LearningMaterial[]>>('/materials');
    return res.data.data;
  },

  async getById(id: number): Promise<LearningMaterial> {
    const res = await api.get<ApiResponse<LearningMaterial>>(`/materials/${id}`);
    return res.data.data;
  },

  async create(data: Partial<LearningMaterial>): Promise<LearningMaterial> {
    const res = await api.post<ApiResponse<LearningMaterial>>('/materials', data);
    return res.data.data;
  },

  async update(id: number, data: Partial<LearningMaterial>): Promise<LearningMaterial> {
    const res = await api.put<ApiResponse<LearningMaterial>>(`/materials/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/materials/${id}`);
  },

  async recordView(materialId: number): Promise<void> {
    await api.post(`/materials/${materialId}/views`);
  },

  async getViewers(materialId: number): Promise<{ studentId: number; studentName: string; viewedAt: string }[]> {
    const res = await api.get<ApiResponse<{ studentId: number; studentName: string; viewedAt: string }[]>>(`/materials/${materialId}/viewers`);
    return res.data.data;
  },
};
