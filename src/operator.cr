require "./observer"

module SingleOperator(D, U)
  abstract def apply(upstream : SingleObserver(D)) : SingleObserver(U)
end

module CompletableOperator
  abstract def apply(upstream : CompletableObserver) : CompletableObserver
end

module MaybeOperator(D, U)
  abstract def apply(upstream : MaybeObserver(D)) : MaybeObserver(U)
end

module ObservableOperator(D, U)
  abstract def apply(upstream : ObservableObserver(D)) : ObservableObserver(U)
end