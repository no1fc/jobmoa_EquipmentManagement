'use client';

import type { User } from '@/types/user';
import { RoleBadge } from './RoleBadge';
import {
  Table,
  TableHeader,
  TableBody,
  TableRow,
  TableHead,
  TableCell,
} from '@/components/ui/table';

interface UserTableProps {
  users: User[];
  isLoading: boolean;
  onEdit: (user: User) => void;
  onDelete: (user: User) => void;
}

export function UserTable({ users, isLoading, onEdit, onDelete }: UserTableProps) {
  if (isLoading) {
    return <UserTableSkeleton />;
  }

  if (users.length === 0) {
    return (
      <div
        className="flex flex-col items-center justify-center rounded-xl py-16"
        style={{ border: '1px solid rgba(0,0,0,0.1)' }}
      >
        <p className="text-sm text-[#615d59]">사용자가 없습니다.</p>
      </div>
    );
  }

  return (
    <div className="overflow-hidden rounded-xl" style={{ border: '1px solid rgba(0,0,0,0.1)' }}>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>이름</TableHead>
            <TableHead>이메일</TableHead>
            <TableHead>역할</TableHead>
            <TableHead>지점</TableHead>
            <TableHead>연락처</TableHead>
            <TableHead>상태</TableHead>
            <TableHead className="w-[100px]">관리</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {users.map((user) => (
            <TableRow key={user.userId}>
              <TableCell className="font-medium">{user.name}</TableCell>
              <TableCell className="text-[#615d59]">{user.email}</TableCell>
              <TableCell>
                <RoleBadge role={user.role} />
              </TableCell>
              <TableCell className="text-[#615d59]">{user.branchName ?? '-'}</TableCell>
              <TableCell className="text-[#615d59]">{user.phone ?? '-'}</TableCell>
              <TableCell>
                {user.isActive ? (
                  <span className="inline-flex items-center rounded-full bg-green-50 px-2 py-0.5 text-xs font-semibold text-green-700">
                    활성
                  </span>
                ) : (
                  <span className="inline-flex items-center rounded-full bg-gray-100 px-2 py-0.5 text-xs font-semibold text-gray-500">
                    비활성
                  </span>
                )}
              </TableCell>
              <TableCell>
                <div className="flex gap-1">
                  <button
                    type="button"
                    onClick={() => onEdit(user)}
                    className="rounded p-1 text-[#615d59] transition-colors hover:bg-accent hover:text-foreground"
                    aria-label={`${user.name} 수정`}
                  >
                    <EditIcon />
                  </button>
                  {user.isActive && (
                    <button
                      type="button"
                      onClick={() => onDelete(user)}
                      className="rounded p-1 text-[#615d59] transition-colors hover:bg-red-50 hover:text-red-600"
                      aria-label={`${user.name} 비활성화`}
                    >
                      <TrashIcon />
                    </button>
                  )}
                </div>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function UserTableSkeleton() {
  return (
    <div className="overflow-hidden rounded-xl" style={{ border: '1px solid rgba(0,0,0,0.1)' }}>
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>이름</TableHead>
            <TableHead>이메일</TableHead>
            <TableHead>역할</TableHead>
            <TableHead>지점</TableHead>
            <TableHead>연락처</TableHead>
            <TableHead>상태</TableHead>
            <TableHead className="w-[100px]">관리</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {Array.from({ length: 5 }).map((_, i) => (
            <TableRow key={i}>
              {Array.from({ length: 7 }).map((__, j) => (
                <TableCell key={j}>
                  <div className="h-4 w-20 animate-pulse rounded bg-muted" />
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}

function EditIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21.174 6.812a1 1 0 0 0-3.986-3.987L3.842 16.174a2 2 0 0 0-.5.83l-1.321 4.352a.5.5 0 0 0 .623.622l4.353-1.32a2 2 0 0 0 .83-.497z" />
    </svg>
  );
}

function TrashIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M3 6h18" /><path d="M19 6v14c0 1-1 2-2 2H7c-1 0-2-1-2-2V6" /><path d="M8 6V4c0-1 1-2 2-2h4c1 0 2 1 2 2v2" />
    </svg>
  );
}
