import { Box, Chip } from '@mui/material';
import type { FilterType } from '../types';

interface TodoFiltersProps {
  current: FilterType;
  counts: { all: number; active: number; completed: number };
  onChange: (filter: FilterType) => void;
}

const filters: { label: string; value: FilterType }[] = [
  { label: 'All', value: 'all' },
  { label: 'Active', value: 'active' },
  { label: 'Completed', value: 'completed' },
];

const chipColor: Record<FilterType, 'primary' | 'info' | 'success'> = { all: 'primary', active: 'info', completed: 'success' };

export default function TodoFilters({ current, counts, onChange }: TodoFiltersProps) {
  return <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap' }}>{filters.map(({ label, value }) => <Chip key={value} label={`${label} (${counts[value]})`} clickable color={current === value ? chipColor[value] : 'default'} variant={current === value ? 'filled' : 'outlined'} onClick={() => onChange(value)} size="small" />)}</Box>;
}
