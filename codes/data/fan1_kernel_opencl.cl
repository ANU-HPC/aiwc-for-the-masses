__kernel void Fan1(__global float *m_dev,
	      __global float *a_dev,
					                        const int size,
								                  const int t) {
    int gid = get_local_id(0) + get_group_id(0) * get_local_size(0) ;//get_global_id(0);

    if (gid < size-1-t) {
         *(m_dev + size * (gid + t + 1)+t) = *(a_dev + size * (gid + t + 1) + t) / *(a_dev + size * t + t);
    }
}

