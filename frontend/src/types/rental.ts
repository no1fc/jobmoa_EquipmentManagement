export type RentalStatus = 'RENTED' | 'RETURNED' | 'OVERDUE' | 'CANCELLED';

export interface Rental {
  rentalId: number;
  assetId: number;
  assetName: string;
  assetCode: string;
  borrowerId: number;
  borrowerEmail: string;
  borrowerName: string;
  rentalReason: string | null;
  rentalDate: string;
  dueDate: string;
  returnDate: string | null;
  status: RentalStatus;
  extensionCount: number;
  returnCondition: string | null;
}

export interface RentalCreateRequest {
  assetId: number;
  borrowerId?: number;
  rentalReason?: string;
  borrowerName?: string;
  dueDays: number;
}

export interface RentalReturnRequest {
  returnCondition?: string;
}

export interface RentalExtendRequest {
  extensionDays: number;
}

export interface RentalDashboard {
  totalActive: number;
  overdueCount: number;
  dueSoon: number;
  returnedToday: number;
}

export interface RentalSearchParams {
  page?: number;
  size?: number;
  status?: RentalStatus;
  borrowerId?: number;
  assetId?: number;
  sort?: string;
  search?: string;
}
