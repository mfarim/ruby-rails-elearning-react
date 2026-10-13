import api from '../api/client';
import type { Announcement, ApiResponse } from '../types';

export const announcementService = {
  async getAll(): Promise<Announcement[]> {
    const res = await api.get<ApiResponse<Announcement[]>>('/announcements');
    return res.data.data;
  },

  async create(data: { title: string; content: string; target: string; published: boolean }): Promise<Announcement> {
    const res = await api.post<ApiResponse<Announcement>>('/announcements', data);
    return res.data.data;
  },

  async update(id: number, data: Partial<Announcement>): Promise<Announcement> {
    const res = await api.put<ApiResponse<Announcement>>(`/announcements/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/announcements/${id}`);
  },
};
