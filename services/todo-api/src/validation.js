export function validateNewTask(body) {
  if (!body || typeof body.title !== 'string') return { error: 'title must be a string' };
  const title = body.title.trim();
  return !title || title.length > 500 ? { error: 'title must contain 1 to 500 characters' } : { value: { title } };
}

export function validateTaskPatch(body) {
  return !body || typeof body.completed !== 'boolean' ? { error: 'completed must be a boolean' } : { value: { completed: body.completed } };
}
