import api from '../api/client';
import type { ApiResponse, AuthResponse, User } from '../types';

export const authService = {
  async login(email: string, password: string):Promise<AuthResponse> {
    const res = await api.post<ApiResponse<AuthResponse>>('/auth/login', { email, password });
    return res.data.data;
  },

  async register(data: { name: string; email: string; password: string; nis?: string; gender?: string }): Promise<AuthResponse> {
    const res = await api.post<ApiResponse<AuthResponse>>('/auth/register', data);
    return res.data.data;
  },

  async getProfile(): Promise<User> {
    const res = await api.get<ApiResponse<User>>('/auth/me');
    return res.data.data;
  },

  async impersonate(userId: number): Promise<AuthResponse> {
    const res = await api.post<ApiResponse<AuthResponse>>(`/admin/impersonate/${userId}`);
    return res.data.data;
  },

  async stopImpersonate(): Promise<AuthResponse> {
    const res = await api.post<ApiResponse<AuthResponse>>('/admin/stop-impersonate');
    return res.data.data;
  },
};
