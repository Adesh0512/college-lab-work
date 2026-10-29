from collections import deque

graph = {
    'A': ['B', 'C', 'D'],
    'B': ['A', 'E', 'F'],
    'C': ['A', 'F'],
    'D': ['A'],
    'E': ['B'],
    'F': ['B', 'C']
}

def bfs(start):
    visited = set()
    queue = deque([start])

    visited.add(start)

    print("BFS Traversal:")

    while queue:
        node = queue.popleft()
        print(node, end=" ")

        for neighbour in graph[node]:
            if neighbour not in visited:
                visited.add(neighbour)
                queue.append(neighbour)

start = 'A'

bfs(start)