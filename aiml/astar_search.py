graph = {
    'A': {'B': 2, 'E': 3},
    'B': {'C': 1, 'G': 9},
    'C': {},
    'E': {'D': 6},
    'D': {'G': 1},
    'G': {}
}

h = {'A': 11, 'B': 6, 'C': 99, 'D': 1, 'E': 7, 'G': 0}

def astar(start, goal):
    open_list = [(h[start], 0, start, [start])]
    
    while open_list:
        open_list.sort()
        f, g, node, path = open_list.pop(0)
        
        if node == goal:
            return path, g
        
        for next_node, cost in graph[node].items():
            new_g = g + cost
            new_f = new_g + h[next_node]
            open_list.append((new_f, new_g, next_node, path + [next_node]))

path, cost = astar('A', 'G')

print("Path:", " -> ".join(path))
print("Cost:", cost)