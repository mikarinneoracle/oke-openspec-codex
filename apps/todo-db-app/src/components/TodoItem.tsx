import { Box, Checkbox, IconButton, ListItem, ListItemIcon, ListItemText, Tooltip } from '@mui/material';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutlined';
import type { Task } from '../types';

interface TodoItemProps {
  task: Task;
  onToggle: (id: string) => void;
  onDelete: (id: string) => void;
}

export default function TodoItem({ task, onToggle, onDelete }: TodoItemProps) {
  return (
    <ListItem disablePadding sx={{ py: 0.25, opacity: task.completed ? 0.5 : 1, transition: 'opacity 0.2s', pr: '48px' }} secondaryAction={<Tooltip title="Delete task"><IconButton edge="end" size="small" aria-label={`Delete task: ${task.title}`} onClick={() => onDelete(task.id)} sx={{ color: 'text.disabled', '&:hover': { color: 'error.main' } }}><DeleteOutlineIcon fontSize="small" /></IconButton></Tooltip>}>
      <ListItemIcon sx={{ minWidth: 40 }}><Checkbox edge="start" checked={task.completed} onChange={() => onToggle(task.id)} size="small" slotProps={{ input: { 'aria-label': `Mark "${task.title}" as ${task.completed ? 'active' : 'completed'}` } }} /></ListItemIcon>
      <ListItemText primary={<Box sx={{ display: 'flex', alignItems: 'center', minWidth: 0 }}><span style={{ textDecoration: task.completed ? 'line-through' : 'none', minWidth: 0, overflowWrap: 'break-word', wordBreak: 'break-word' }}>{task.title}</span></Box>} slotProps={{ primary: { sx: { color: task.completed ? 'text.disabled' : 'text.primary', transition: 'color 0.2s' } } }} />
    </ListItem>
  );
}
