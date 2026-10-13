import api from '../api/client';
import type { ApiResponse, GradeReportResponse } from '../types';

export const gradeService = {
  async getStudentGrades(): Promise<GradeReportResponse> {
    const res = await api.get<ApiResponse<GradeReportResponse>>('/student/grades');
    return res.data.data;
  },
};
