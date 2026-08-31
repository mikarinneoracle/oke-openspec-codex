import { Box, Button, Typography } from '@mui/material';
import DeleteSweepIcon from '@mui/icons-material/DeleteSweep';

interface TodoFooterProps {
  activeCount: number;
  completedCount: number;
  onClearCompleted: () => void;
}

export default function TodoFooter({ activeCount, completedCount, onClearCompleted }: TodoFooterProps) {
  return (
    <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: 1, py: 0.5 }}>
      <Typography variant="body2" color="text.secondary">{activeCount} {activeCount === 1 ? 'task' : 'tasks'} remaining</Typography>
      <Button size="small" variant="text" color="inherit" startIcon={<DeleteSweepIcon fontSize="small" />} disabled={completedCount === 0} onClick={onClearCompleted} sx={{ color: 'text.secondary', textTransform: 'none', fontSize: '0.8125rem' }}>Clear completed</Button>
    </Box>
  );
}
