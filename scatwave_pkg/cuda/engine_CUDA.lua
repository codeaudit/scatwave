local ffi = require 'ffi'
local cuFFT = {}

local ok, cuFFT_lib = pcall(function () return ffi.load('cufft') end)

if(not ok) then
   error('library cufft not found...')
end

-- defines types
ffi.cdef[[
typedef double fftw_complex[2];
typedef float fftwf_complex[2];

typedef struct {
    int n;
    int is;
    int os;
} fftw_iodim;

typedef fftw_iodim fftwf_iodim;

typedef void *fftwf_plan;
typedef void *fftw_plan;]]


-- defines structures
ffi.cdef[[
extern fftw_plan fftw_plan_guru_dft_r2c(int rank, const fftw_iodim *dims,
                                          int batch_rank, const fftw_iodim *batch_dims,
                                          double *in, fftw_complex *out, 
                                          unsigned flags);


extern fftw_plan fftw_plan_guru_dft(int rank, const fftw_iodim *dims,
                                      int batch_rank, const fftw_iodim *batch_dims,
                                      fftw_complex *in, fftw_complex *out,
                                      int sign, unsigned flags);


extern fftwf_plan fftwf_plan_guru_dft(int rank, const fftwf_iodim *dims,
                                        int batch_rank, const fftwf_iodim *batch_dims,
                                        fftwf_complex *in, fftwf_complex *out,
                                        int sign, unsigned flags);
                                        
extern fftwf_plan fftwf_plan_guru_dft_r2c(int rank, const fftwf_iodim *dims,
                                            int batch_rank, const fftwf_iodim *batch_dims,
                                            float *in, fftwf_complex *out, 
                                            unsigned flags);
void fftw_execute(const fftw_plan plan);
]]

-- defines constant 
cuFFT.FORWARD  = -1
cuFFT.BACKWARD =  1
cuFFT.ESTIMATE = 64

-- registers function in a "soumith" style. It checks that function exists before adding it to the list!
local function register(luafuncname, funcname)
   local symexists, msg = pcall(function()
                              local sym = cuFFT_lib[funcname]
                           end)
   if symexists then
      cuFFT[luafuncname] = cuFFT_lib[funcname]
   else 

      error(string.format('%s of the library cuFFT not found!',funcname))
   end
end

register('execute','fftw_execute')
--register('plan_guru_dft_r2c_f','fftwf_plan_guru_dft_r2c')
--register('plan_guru_dft_r2c_f','fftwf_plan_guru_dft_r2c')
register('plan_guru_dft','fftw_plan_guru_dft')


return cuFFT