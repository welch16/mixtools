\name{spEM}
\title{Semiparametric EM-like Algorithm for Mixtures of Independent Repeated Measurements}
\alias{spEM}
\usage{
spEM(x, mu0, blockid = 1:ncol(x), 
     bw = bw.nrd0(as.vector(as.matrix(x))), constbw = TRUE, 
     h = bw, eps = 1e-8, 
     maxiter = 500, stochastic = FALSE, verb = TRUE)
}

\description{
  Returns semiparametric EM algorithm output (Benaglia et al, 2009) for mixtures
  of multivariate (repeated measures) data where the coordinates of a row (case)
  in the data matrix are assumed to be independent, conditional on the mixture
  component (subpopulation) from which they are drawn.
  For now, this algorithm only implements model (4.7) in 
  Benaglia et al, in which each component and block has exactly
  the same (nonparametric) shape and they differ only by location and scale.
}
\arguments{
  \item{x}{An \eqn{n\times r}{n x r} matrix of data.  Each of the \eqn{n} rows is a case,
  and each case has \eqn{r} repeated measurements.  These measurements are assumed
  to be conditionally independent, conditional on the mixture component (subpopulation) 
  from which the case is drawn.}
  \item{mu0}{Either an \eqn{m\times r}{m x r} matrix specifying the initial
      centers for the \link{kmeans} function, or an integer \eqn{m} specifying the 
      number of initial centers, which are then choosen randomly in
  \link{kmeans}}
  \item{blockid}{A vector of length \eqn{r} identifying coordinates 
  (columns of \code{x}) that are
  assumed to be identically distributed (i.e., in the same block).  For instance,
  the default has all distinct elements, indicating that no two coordinates 
  are assumed identically distributed and thus a separate set of \eqn{m} 
  density estimates is produced for each column of \eqn{x}.  On the other hand,
  if \code{blockid=rep(1,ncol(x))}, then the coordinates in each row 
  are assumed conditionally i.i.d.}
  \item{bw}{Bandwidth for density estimation, equal to the standard deviation 
  of the kernel density.  By default, a simplistic application of the 
  default \code{\link{bw.nrd0}} 
  bandwidth used by \code{\link{density}} to the entire dataset.}
  \item{constbw}{Logical:  If \code{TRUE}, use the same bandwidth for
  each iteration and for each component and block.  If \code{FALSE}, 
  use a separate bandwidth for each component and block, and update
  this bandwidth at each iteration of the algorithm using a suitably
  modified \code{\link{bw.nrd0}} method as described in 
  Benaglia et al (2011).}
  \item{h}{Alternative way to specify the bandwidth, to provide backward 
  compatibility.}
  \item{eps}{Tolerance limit for declaring algorithm convergence.  Convergence
  is declared whenever the maximum change in any coordinate of the 
  \code{lambda} vector (of mixing proportion estimates) does not exceed 
  \code{eps}.}

  \item{maxiter}{The maximum number of iterations allowed, for both 
  stochastic and non-stochastic versions; 
  for non-stochastic algorithms (\code{stochastic = FALSE}), convergence
  may be declared before \code{maxiter} iterations (see \code{eps} above).}
  
  \item{stochastic}{Flag, if FALSE (the default), runs the non-stochastic version
      of the npEM algorithm, as in Benaglia et al (2009). Set to TRUE to
      run a stochastic version which simulates the posteriors at each
      iteration, and runs for \code{maxiter} iterations.}

  \item{verb}{If TRUE, print updates for every iteration of the algorithm as
  it runs}
}
\value{
\code{spEM} returns a list of class \code{spEM} with the following items:
  \item{data}{The raw data (an \eqn{n\times r}{n x r} matrix).}
  \item{posteriors}{An \eqn{n\times m}{n x m} matrix of posterior probabilities for
   observation. If \code{stochastic = TRUE}, this matrix is computed 
   from an average over the \code{maxiter} iterations.}
  \item{bandwidth}{If \code{constbw==TRUE}, 
  same as the \code{bw} input argument; otherwise, value of \code{bw} matrix
  at final iteration (since for now this algorithm only implements 
  model (4.7) in Benaglia et al, the bandwidth matrix is reduced to a single
  bandwith scalar).  
  This
  information is needed by any method that produces density estimates from the
  output.}
  \item{blockid}{Same as the \code{blockid} input argument, but recoded to have
  positive integer values.  Also needed by any method that produces density 
  estimates from the output.}
  \item{lambda}{The sequence of mixing proportions over iterations.}
  \item{lambdahat}{The final mixing proportions if \code{stochastic = FALSE}, 
  or the average mixing proportions if \code{stochastic = TRUE}.}
  \item{mu}{The sequence of location parameters over iterations.}
  \item{muhat}{The final location parameters if \code{stochastic = FALSE}, 
  or the average location parameters if \code{stochastic = TRUE}.}
  \item{sigma}{The sequence of scale parameters over iterations.}
  \item{sigmahat}{The final scale parameters if \code{stochastic = FALSE}, 
  or the average scale parameters if \code{stochastic = TRUE}.}
  \item{loglik}{The sequence of log-likelihoods over iterations.}
}
\seealso{
\code{\link{plot.spEM}}, \code{\link{normmixrm.sim}}, \code{\link{spEMsymloc}},
\code{\link{npEM}}, \code{\link{plotseq.npEM}}
}
\references{
   \itemize{
   \item Benaglia, T., Chauveau, D., and Hunter, D. R., An EM-like algorithm
   for semi- and non-parametric estimation in multivariate mixtures, 
   Journal of Computational and Graphical Statistics, 18, 505-526, 2009.
   
   \item Benaglia, T., Chauveau, D. and Hunter, D.R.
 	Bandwidth Selection in an EM-like algorithm for nonparametric multivariate mixtures.
	Nonparametric Statistics and Mixture Models: A Festschrift in
  	Honor of Thomas P. Hettmansperger. World Scientific Publishing Co., 
  	pages 15-27, 2011.
   
   \item Bordes, L., Chauveau, D., and Vandekerkhove, P.,
   An EM algorithm for a semiparametric mixture model, 
   Computational Statistics and Data Analysis, 51: 5429-5443, 2007.
   }
}
\examples{\dontrun{
## simulate a 2-component gaussian mixture with 3 iid repeated measures
set.seed(100)
mu <- matrix(c(0, 15), 2, 3)
sigma <- matrix(c(1, 5), 2, 3)
x <- rmvnormmix(300, lambda = c(.4,.6), mu = mu, sigma = sigma)

## apply spEM with or without an iterative bandwidth selection
d <- spEM(x, mu0 = 2, blockid = rep(1,3), constbw = FALSE)
d2 <- spEM(x, mu0 = 2, blockid = rep(1,3), constbw = TRUE)
plot(d, xlim=c(-10, 40), ylim = c(0, .16), xlab = "", breaks = 30,
     cex.lab=1.5, cex.axis=1.5, addlegend=FALSE)
plot(d2, newplot=FALSE, addlegend=FALSE, lty=2)}
}


\keyword{file}
