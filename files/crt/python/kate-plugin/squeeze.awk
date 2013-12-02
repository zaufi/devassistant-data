BEGIN {
    count=0;
}
{
    if ($0=="")
        count++; 
    else
        count=0;

    if (count <3)
        print;
}
