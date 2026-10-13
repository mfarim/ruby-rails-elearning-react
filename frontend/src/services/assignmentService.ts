import api from '../api/client';
import type { ApiResponse, Assignment, Discussion, Submission } from '../types';

export const assignmentService = {
  async getAll(): Promise<Assignment[]> {
    const res = await api.get<ApiResponse<Assignment[]>>('/assignments');
    return res.data.data;
  },

  async getById(id: number): Promise<Assignment> {
    const res = await api.get<ApiResponse<Assignment>>(`/assignments/${id}`);
    return res.data.data;
  },

  async create(data: Partial<Assignment>): Promise<Assignment> {
    const res = await api.post<ApiResponse<Assignment>>('/assignments', data);
    return res.data.data;
  },

  async update(id: number, data: Partial<Assignment>): Promise<Assignment> {
    const res = await api.put<ApiResponse<Assignment>>(`/assignments/${id}`, data);
    return res.data.data;
  },

  async delete(id: number): Promise<void> {
    await api.delete(`/assignments/${id}`);
  },

  async submit(assignmentId: number, data: { filePath?: string; notes?: string }): Promise<Submission> {
    const res = await api.post<ApiResponse<Submission>>(`/assignments/${assignmentId}/submit`, data);
    return res.data.data;
  },

  async getSubmissions(assignmentId: number): Promise<Submission[]> {
    const res = await api.get<ApiResponse<Submission[]>>(`/assignments/${assignmentId}/submissions`);
    return res.data.data;
  },

  async gradeSubmission(submissionId: number, data: { score: number; feedback?: string }): Promise<Submission> {
    const res = await api.post<ApiResponse<Submission>>(`/assignments/submissions/${submissionId}/grade`, data);
    return res.data.data;
  },

  async getDiscussions(assignmentId: number): Promise<Discussion[]> {
    const res = await api.get<ApiResponse<Discussion[]>>(`/assignments/${assignmentId}/discussions`);
    return res.data.data;
  },

  async createDiscussion(assignmentId: number, data: { parentId?: number | null; message: string }): Promise<Discussion> {
    const res = await api.post<ApiResponse<Discussion>>(`/assignments/${assignmentId}/discussions`, data);
    return res.data.data;
  },
};
