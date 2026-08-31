import { useMemo, useState } from 'react';
import {
  Box,
  Button,
  Container,
  CssBaseline,
  Divider,
  Paper,
  ThemeProvider,
  Typography,
  createTheme,
  useMediaQuery,
} from '@mui/material';
import type { FilterType, Task } from './types';
import AddTaskDialog from './components/AddTaskDialog';
import TodoFilters from './components/TodoFilters';
import TodoFooter from './components/TodoFooter';
import TodoList from './components/TodoList';
import { initialTasks } from './data/initialTasks';

const theme = createTheme({
  palette: {
    mode: 'light',
    primary: { main: '#171717', dark: '#000000', light: '#3c3c3c', contrastText: '#fff' },
    background: { default: '#F5F5F5', paper: '#ffffff' },
    text: { primary: '#171717', secondary: '#5c5c5c' },
    divider: '#E0E0E0',
  },
  shape: { borderRadius: 16 },
  typography: { fontFamily: 'Roboto, sans-serif' },
  components: {
    MuiButton: {
      styleOverrides: { root: { textTransform: 'none' } },
      defaultProps: { disableRipple: true, disableElevation: true, variant: 'outlined' },
    },
    MuiPaper: { styleOverrides: { root: { borderRadius: 24 }, elevation1: { boxShadow: '0px 6px 12px rgba(0, 0, 0, 0.05)' } } },
    MuiChip: { styleOverrides: { root: { fontWeight: 500 } } },
  },
});

function TodoApp() {
  const [tasks, setTasks] = useState<Task[]>(initialTasks);
  const [filter, setFilter] = useState<FilterType>('all');
  const [dialogOpen, setDialogOpen] = useState(false);
  const isMobile = useMediaQuery(theme.breakpoints.down('sm'));
  const counts = useMemo(() => ({
    all: tasks.length,
    active: tasks.filter((task) => !task.completed).length,
    completed: tasks.filter((task) => task.completed).length,
  }), [tasks]);
  const visibleTasks = useMemo(() => {
    if (filter === 'active') return tasks.filter((task) => !task.completed);
    if (filter === 'completed') return tasks.filter((task) => task.completed);
    return tasks;
  }, [tasks, filter]);

  return (
    <>
      <Box sx={{ bgcolor: 'background.default', minHeight: '100vh', py: { xs: 3, sm: 4 }, display: 'flex', alignItems: 'center' }}>
        <Container maxWidth="sm" sx={{ px: { xs: 2, sm: 3 } }}>
          <Paper sx={{ border: 1, borderColor: 'divider', overflow: 'hidden' }}>
            <Box sx={{ p: isMobile ? 2 : 3, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <Typography variant="h5" component="h1">To-do list</Typography>
              <Button onClick={() => setDialogOpen(true)} size={isMobile ? 'small' : 'medium'}>Add new task</Button>
            </Box>
            <Divider />
            <Box sx={{ px: isMobile ? 2 : 3, py: 1.5 }}><TodoFilters current={filter} counts={counts} onChange={setFilter} /></Box>
            <Divider />
            <Box sx={{ px: isMobile ? 1 : 2, py: 0.5, height: '40vh', overflowY: 'auto', display: 'flex', flexDirection: 'column' }}>
              <TodoList tasks={visibleTasks} filter={filter} onToggle={(id) => setTasks((current) => current.map((task) => task.id === id ? { ...task, completed: !task.completed } : task))} onDelete={(id) => setTasks((current) => current.filter((task) => task.id !== id))} />
            </Box>
            <Divider />
            <Box sx={{ px: isMobile ? 2 : 3, py: 1.5 }}><TodoFooter activeCount={counts.active} completedCount={counts.completed} onClearCompleted={() => setTasks((current) => current.filter((task) => !task.completed))} /></Box>
          </Paper>
        </Container>
      </Box>
      <AddTaskDialog open={dialogOpen} onAdd={(title) => setTasks((current) => [{ id: crypto.randomUUID(), title, completed: false }, ...current])} onClose={() => setDialogOpen(false)} />
    </>
  );
}

export default function App() {
  return <ThemeProvider theme={theme}><CssBaseline /><TodoApp /></ThemeProvider>;
}
