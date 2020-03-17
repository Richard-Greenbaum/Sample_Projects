# CryptoKeychain

CryptoKeychain is a secure password management Android application. The app, as other keychain apps
do, uses a Password Based Key Derivation Function (PBKDF2) to generate a key from the user's master
password to encrypt (using AES-CBC) the passwords stored in the user's vault. Later sections discuss
in the cryptographic primitives used to achieve maximum security in greater detail.

## Attacker Model
A cryptographic attacker model is composed of the presumed goals and capabilities that an attacker 
of a system would have. For our application, the goals of an attacker include obtaining the master 
password, obtaining the password-based encryption key, obtaining a specific account password stored 
in the app, and predicting the output of the secure random passwords provided by the app. The main 
attacker capability that we will assume when creating our application is that the attacker will gain
access to the memory of the device at some point in time, and that they will be able to identify the
location in memory of the passwords stored by the app. For this reason all passwords stored in memory
will be encrypted, and the amount of time that unencrypted passwords spend in memory will be minimized.
We also assume that the attacker knows the cryptographic primitives that we are using to encrypt the 
passwords, allowing him or her to mount an offline dictionary attack and verify the correctness of a
candidate master password. Thus the security of our application cannot be reliant on the secrecy of 
our algorithms.

## Strength of Master Password and Key Derivation
Keychain applications provide utility to their user by reducing the number of passwords that they 
need to keep track of. While the ability of one single password to unlock countless other passwords
is the primary utility of the app, it also creates a great cryptographic risk to the user, because
it exposes the stored passwords to an attacker if they are able to guess just the master password.
We have several application components in place to protect the master password. The first is
that we require that the master password be at least 8 characters long. This ensures that the 
state space of possible passwords is very large. Assuming that each character can consist of an 
upper or lower case letter, a number, or a special character, the state space of an 8 digit 
password is 91<sup>8</sup> passwords long.

Furthermore, the master password is not stored directly in the device’s memory. Instead, a hash value 
is computed by hashing the master password with the Kotlin hashCode function and then repeatedly 
hashing the output of the function for half a second. When the user tries to log in at a later 
time, the hash of the input password will be computed in the same way and then it will be compared 
to the stored hash value in Android Shared Preferences. If the values are equal, then the user inputted
the correct master password. Otherwise they did not. Note the increase in security that is gained by
repeatedly hashing for half a second, protecting even fairly weak passwords. As an example, assume that the 
user created an 8 digit password that consists only of lowercase letters, and that the attacker 
has this information. This will result in a brute force attack on 26<sup>8</sup> possible passwords. For an 
attacker to generate and verify each possible password, they would need (26<sup>8</sup>)/2 seconds, or more 
than 3300 years. The odds that the attacker would arrive at the correct password in the first 10 
years is less than 0.3%. 

## Password Encryption
We encrypt the user’s data (account names, usernames, and passwords) using the recommended Advanced
Encryption Standard (AES). Since AES uses a substitution-permutation network to encrypt data 
(with a given key), it replaces bytes from one table with the bytes from another, and as such creates
permutations of data. The AES key generated in the app is 256 bits long and is derived from using a 
Password-Based Key Derivation Function (PBKDF2) on the user’s master password. Using a 256-bit key 
with AES makes for a key space that has size 1.1 * 1077, which would make a brute force attack on the
key infeasible even by a supercomputer. Since PBKDF2 hashes a password with a salt many times over, 
even if two users happen to use the same password, the key will be unique. This prevents one key, 
if published online, from potentially being used to expose the data of multiple users.

In order to generate the salt, we use the Kotlin cryptographically strong pseudo-random generator 
function SecureRandom(), and set the salt to be sufficiently long such that it would be computationally
infeasible for an attacker to try all possible passwords (i.e. due to the Birthday paradox, choosing 
salt length to be 64 leads to an expected collision after 232 (or 4 billion) passwords). We then create
a password based encryption object (in Kotlin, this is known as a PBEKeySpec object), passing as input
the user’s master password, the pseudo-randomly generated salt, the iteration count (NIST guidelines 
recommend a minimum of 10,000 iterations, but due to security-performance tradeoffs, we opt for a smaller
number of iterations), and the length of the key (in our case, 256). We then pass this object into a 
secretKeyFactory object which outputs the AES symmetric encryption key, while also allowing us to specify
the cryptographic algorithm we would like to use (in our case, PBKDF2WithHmacSHA256).

To encrypt a password, we use AES CBC with the encryption key and a random IV generated using the 
SecureRandom() function. We then store the encrypted password as well as the unencrypted IV. 
Storing the unencrypted IV allows us to decrypt later on (assuming we have the same key). Note that
using CBC encryption with a different random IV for each password ensures that, if the user uses the
same password for several accounts, the encrypted passwords will all be different. Thus the attacker will
not know that the user has duplicate passwords, and no information will be leaked. 

## Secure Password Generation
Password auto-generation is performed using the SecureRandom() function mentioned earlier. Users are also 
given the option to configure password auto-generation to the requirements they are seeking. Suppose, 
for example, that a website or native app does not allow long passwords, or the dash symbol, or any other
property that the default password auto-generation algorithm performs; the user is allowed to put some 
constraints on this algorithm so that a secure password is still generated for them (within the confines
of the restrictions they place on the auto-generation function).
