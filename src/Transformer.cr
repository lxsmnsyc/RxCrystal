require "./*"

module SingleTransformer(U, D)
  abstract def apply(upstream : Single(U)) : Single(D)
end

module CompletableTransformer
  abstract def apply(upstream : Completable) : Completable
end

module MaybeTransformer(U, D)
  abstract def apply(upstream : Maybe(U)) : Maybe(D)
end

module ObservableTransformer(U, D)
  abstract def apply(upstream : Observable(U)) : Observable(D)
end
