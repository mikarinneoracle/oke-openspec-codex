import { Box, Divider, List, Typography } from '@mui/material';
import CheckCircleOutlineIcon from '@mui/icons-material/CheckCircleOutlined';
import InboxIcon from '@mui/icons-material/Inbox';
import type { FilterType, Task } from '../types';
import TodoItem from './TodoItem';

interface TodoListProps {
  tasks: Task[];
  filter: FilterType;
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
}

function EmptyState({ filter }: { filter: FilterType }) {
  const config = {
    all: { icon: <InboxIcon sx={{ fontSize: 48, color: 'text.disabled' }} />, primary: 'No tasks yet', secondary: 'Add a task above to get started.' },
    active: { icon: <CheckCircleOutlineIcon sx={{ fontSize: 48, color: 'success.light' }} />, primary: 'All done!', secondary: 'You have no active tasks.' },
    completed: { icon: <InboxIcon sx={{ fontSize: 48, color: 'text.disabled' }} />, primary: 'Nothing completed yet', secondary: 'Complete a task and it will appear here.' },
  }[filter];
  return <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 1.5, height: '100%', py: 6, px: 2, color: 'text.secondary' }}>{config.icon}<Typography variant="subtitle1" sx={{ fontWeight: 500 }}>{config.primary}</Typography><Typography variant="body2" color="text.disabled">{config.secondary}</Typography></Box>;
}

export default function TodoList({ tasks, filter, onToggle, onDelete }: TodoListProps) {
  if (tasks.length === 0) return <EmptyState filter={filter} />;
  return <List disablePadding>{tasks.map((task, index) => <Box key={task.id}><TodoItem task={task} onToggle={onToggle} onDelete={onDelete} />{index < tasks.length - 1 && <Divider component="li" sx={{ mx: 1 }} />}</Box>)}</List>;
}
