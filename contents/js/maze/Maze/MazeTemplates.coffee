Maze = @Maze ||= {}

# Templates
Maze.Templates = {}
Maze.Templates.GraphPaper = $.extend Maze.Structures.GraphPaper,
  projection: new Maze.Projections.GraphPaper()

Maze.Templates.FoldedHexagon = $.extend Maze.Structures.FoldedHexagon,
  projection: new Maze.Projections.FoldedHexagonCell()