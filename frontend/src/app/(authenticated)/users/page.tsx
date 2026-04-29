'use client';

import { useState, useCallback } from 'react';
import { useUsers } from '@/hooks/useUsers';
import { UserFilters } from '@/components/users/UserFilters';
import { UserTable } from '@/components/users/UserTable';
import { CreateUserDialog } from '@/components/users/CreateUserDialog';
import { EditUserDialog } from '@/components/users/EditUserDialog';
import { DeleteUserDialog } from '@/components/users/DeleteUserDialog';
import { Button } from '@/components/ui/button';
import type { User } from '@/types/user';

interface UserSearchParams {
  page?: number;
  size?: number;
  sort?: string;
  role?: string;
  search?: string;
}

const DEFAULT_PARAMS: UserSearchParams = {
  page: 0,
  size: 20,
  sort: 'createdAt,desc',
};

export default function UsersPage() {
  const [params, setParams] = useState<UserSearchParams>(DEFAULT_PARAMS);
  const { data: pageData, isLoading } = useUsers(params);

  const [createDialogOpen, setCreateDialogOpen] = useState(false);
  const [editUser, setEditUser] = useState<User | null>(null);
  const [deleteUser, setDeleteUser] = useState<User | null>(null);

  const handleParamsChange = useCallback((partial: Partial<UserSearchParams>) => {
    setParams((prev) => ({ ...prev, ...partial }));
  }, []);

  const handlePageChange = useCallback((page: number) => {
    setParams((prev) => ({ ...prev, page }));
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-[26px] font-bold tracking-[-0.625px]">사용자 관리</h1>
        <Button onClick={() => setCreateDialogOpen(true)}>
          <PlusIcon />
          <span className="ml-1.5">사용자 등록</span>
        </Button>
      </div>

      <UserFilters params={params} onParamsChange={handleParamsChange} />

      <UserTable
        users={pageData?.content ?? []}
        isLoading={isLoading}
        onEdit={(user) => setEditUser(user)}
        onDelete={(user) => setDeleteUser(user)}
      />

      {pageData && pageData.totalPages > 1 && (
        <div className="flex items-center justify-between">
          <p className="text-sm text-[#615d59]">
            {pageData.page + 1} / {pageData.totalPages} 페이지 (총 {pageData.totalElements}건)
          </p>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={pageData.page === 0}
              onClick={() => handlePageChange(pageData.page - 1)}
            >
              이전
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={pageData.last}
              onClick={() => handlePageChange(pageData.page + 1)}
            >
              다음
            </Button>
          </div>
        </div>
      )}

      <CreateUserDialog
        open={createDialogOpen}
        onOpenChange={setCreateDialogOpen}
      />

      <EditUserDialog
        user={editUser}
        open={editUser !== null}
        onOpenChange={(open) => { if (!open) setEditUser(null); }}
      />

      <DeleteUserDialog
        user={deleteUser}
        open={deleteUser !== null}
        onOpenChange={(open) => { if (!open) setDeleteUser(null); }}
      />
    </div>
  );
}

function PlusIcon() {
  return (
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M5 12h14" /><path d="M12 5v14" />
    </svg>
  );
}
