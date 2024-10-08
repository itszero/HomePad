extension Sequence {
  func asyncMap<T>(_ transform: @escaping (Element) async -> T) async -> [T] {
    return await withTaskGroup(of: T.self) { group in
      var transformedElements = [T]()
      
      for element in self {
        group.addTask {
          return await transform(element)
        }
      }
      
      for await transformedElement in group {
        transformedElements.append(transformedElement)
      }
      
      return transformedElements
    }
  }
}
