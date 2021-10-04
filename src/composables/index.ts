export const apiCall = async (url: string) => {
    const res = await fetch(url);
    return await res.json();
};