import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/failure.dart';

//! typedef will allow me to define a type
//? FutureEither reason to create is we will always going to have failure as one class
//?Either should first have a failure type

//! <T> => I can give any type
typedef FutureEither<T> = Future<Either<Failure, T>>;

//! success can be void
typedef FutureVoid = FutureEither<void>;
