'use client';

import { useState, useMemo, useCallback } from 'react';
import type { CategoryTree } from '@/types/category';
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from '@/components/ui/select';

interface CategoryCascadeSelectProps {
  value?: number;
  onChange: (categoryId: number | undefined) => void;
  categoryTree: CategoryTree[];
  allowAll?: boolean;
}

interface SelectOption {
  value: string;
  label: string;
}

function buildItems(categories: CategoryTree[], allowAll: boolean): SelectOption[] {
  const options: SelectOption[] = [];
  if (allowAll) {
    options.push({ value: '', label: '전체' });
  }
  for (const cat of categories) {
    options.push({ value: String(cat.categoryId), label: cat.categoryName });
  }
  return options;
}

function findCategoryPath(
  tree: CategoryTree[],
  targetId: number,
): [CategoryTree | null, CategoryTree | null, CategoryTree | null] {
  for (const l1 of tree) {
    if (l1.categoryId === targetId) return [l1, null, null];
    for (const l2 of l1.children) {
      if (l2.categoryId === targetId) return [l1, l2, null];
      for (const l3 of l2.children) {
        if (l3.categoryId === targetId) return [l1, l2, l3];
      }
    }
  }
  return [null, null, null];
}

export function CategoryCascadeSelect({
  value,
  onChange,
  categoryTree,
  allowAll = false,
}: CategoryCascadeSelectProps) {
  // Derive initial state from value prop
  const initialPath = useMemo(() => {
    if (value && categoryTree.length > 0) {
      const [l1, l2, l3] = findCategoryPath(categoryTree, value);
      return {
        level1: l1 ? String(l1.categoryId) : '',
        level2: l2 ? String(l2.categoryId) : '',
        level3: l3 ? String(l3.categoryId) : '',
      };
    }
    return { level1: '', level2: '', level3: '' };
  }, [value, categoryTree]);

  const [level1Id, setLevel1Id] = useState<string>(initialPath.level1);
  const [level2Id, setLevel2Id] = useState<string>(initialPath.level2);
  const [level3Id, setLevel3Id] = useState<string>(initialPath.level3);

  // Sync when value changes externally (e.g. reset)
  const [prevValue, setPrevValue] = useState(value);
  if (value !== prevValue) {
    setPrevValue(value);
    if (value && categoryTree.length > 0) {
      const [l1, l2, l3] = findCategoryPath(categoryTree, value);
      setLevel1Id(l1 ? String(l1.categoryId) : '');
      setLevel2Id(l2 ? String(l2.categoryId) : '');
      setLevel3Id(l3 ? String(l3.categoryId) : '');
    } else if (!value) {
      setLevel1Id('');
      setLevel2Id('');
      setLevel3Id('');
    }
  }

  const selectedL1 = categoryTree.find((c) => String(c.categoryId) === level1Id);
  const level2Options = selectedL1?.children ?? [];
  const selectedL2 = level2Options.find((c) => String(c.categoryId) === level2Id);
  const level3Options = selectedL2?.children ?? [];

  const emitChange = useCallback(
    (l1: string, l2: string, l3: string) => {
      const deepest = l3 || l2 || l1;
      onChange(deepest ? Number(deepest) : undefined);
    },
    [onChange],
  );

  const handleLevel1Change = (val: string | null) => {
    const v = val ?? '';
    setLevel1Id(v);
    setLevel2Id('');
    setLevel3Id('');
    emitChange(v, '', '');
  };

  const handleLevel2Change = (val: string | null) => {
    const v = val ?? '';
    setLevel2Id(v);
    setLevel3Id('');
    emitChange(level1Id, v, '');
  };

  const handleLevel3Change = (val: string | null) => {
    const v = val ?? '';
    setLevel3Id(v);
    emitChange(level1Id, level2Id, v);
  };

  const l1Items = buildItems(categoryTree, allowAll);
  const l2Items = buildItems(level2Options, allowAll && !!level1Id);
  const l3Items = buildItems(level3Options, allowAll && !!level2Id);

  return (
    <div className="flex flex-wrap gap-2">
      <div className="min-w-[140px] flex-1">
        <Select
          value={level1Id}
          onValueChange={handleLevel1Change}
          items={l1Items}
        >
          <SelectTrigger className="w-full">
            <SelectValue placeholder="대분류" />
          </SelectTrigger>
          <SelectContent>
            {l1Items.map((item) => (
              <SelectItem key={item.value} value={item.value}>
                {item.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      {level2Options.length > 0 && (
        <div className="min-w-[140px] flex-1">
          <Select
            value={level2Id}
            onValueChange={handleLevel2Change}
            items={l2Items}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="중분류" />
            </SelectTrigger>
            <SelectContent>
              {l2Items.map((item) => (
                <SelectItem key={item.value} value={item.value}>
                  {item.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}

      {level3Options.length > 0 && (
        <div className="min-w-[140px] flex-1">
          <Select
            value={level3Id}
            onValueChange={handleLevel3Change}
            items={l3Items}
          >
            <SelectTrigger className="w-full">
              <SelectValue placeholder="소분류" />
            </SelectTrigger>
            <SelectContent>
              {l3Items.map((item) => (
                <SelectItem key={item.value} value={item.value}>
                  {item.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      )}
    </div>
  );
}
