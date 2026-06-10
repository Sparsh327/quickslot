export type SlotStatus = 'AVAILABLE' | 'BOOKED';

export interface ApiResponse<T> {
  data?: T;
  error?: string;
}
