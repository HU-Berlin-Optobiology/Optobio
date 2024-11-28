# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 19:44:12 2024

@author: Erich
"""

from PyPDF2 import PdfReader, PdfWriter
from tkinter import *
from tkinter import ttk
from tkinter import filedialog
from tkinter import messagebox

writer = PdfWriter()
# Initiaiting root window
root = Tk()
root.title("PDF page extractor")
root.geometry("900x200")
root.config(bg="black")
root.focus_force()

# Setting up style
style = ttk.Style()
style.configure("CSearch.TButton", font=("Arial", 10))
style.configure("C.TButton", font=("Arial", 10, "underline"))

# Functions
def LoadDir():
    global load_dir
    Dir1 = filedialog.askopenfilename(title="Choose PDF file to load", filetypes=[("pdf file", ".pdf")])
    load_dir.set(Dir1)
    
def SaveDir():
    global save_dir
    Dir2 = filedialog.asksaveasfilename(title="Choose path and name of to be safed PDF file", filetypes=[("pdf file", ".pdf")],
                                   defaultextension=".pdf")
    save_dir.set(Dir2)
    
def DoThings():
    pages = [int(i) for i in ExtractEntry.get().split(",")]
    ExtractEntry.delete(0,"end")
    OpenFile = LoadDirEntry.get()
    SaveFile = SaveDirEntry.get()
    for page in pages:
        fob = open(OpenFile, "rb")
        reader = PdfReader(fob)
        writer.add_page(reader.pages[page])
        outfile = open(SaveFile, "wb")
        writer.write(outfile)
        fob.close()
        outfile.close()
        
        
    
            


    

# Load Directory of PDF
LoadDirLabel = Label(root, text="PDF-Path to read:", bg="black", fg="white")
LoadDirLabel.grid(row=0, column=0, padx=10,pady=10)
load_dir = StringVar()
load_dir.set("Path to the PDF-file to extract pages from")
LoadDirEntry = Entry(root, textvariable=load_dir, bg="black", fg="white", width=70)
LoadDirEntry.grid(row=0, column=1, columnspan=3, padx=10, pady=10)
LoadDirSearchBtn = ttk.Button(root, text="...", width=3, command=LoadDir, style="CSearch.TButton")
LoadDirSearchBtn.grid(row=0, column=4, padx=10, pady=10)

# Save Directory of new PDF
SaveDirLabel = Label(root, text="PDF-Path to save:", bg="black", fg="white")
SaveDirLabel.grid(row=1, column=0)
save_dir = StringVar()
save_dir.set("Path to where PDF shall be safed")
SaveDirEntry = Entry(root, textvariable=save_dir, bg="black", fg="white", width=70)
SaveDirEntry.grid(row=1, column=1, columnspan=3, padx=10, pady=10)
SaveDirSearchBtn = ttk.Button(root, text="...", width=3, command=SaveDir, style="CSearch.TButton")
SaveDirSearchBtn.grid(row=1, column=4, padx=10, pady=10)

# Entry of pages to extract
ExtractLabel = Label(root, text="Pages to extract; seperate with ,:", bg="black", fg="white")
ExtractLabel.grid(row=2, column=0, padx=10, pady=10)
extract = StringVar()
ExtractEntry = Entry(root, textvariable=extract, bg="black", fg="white", width=70)
ExtractEntry.grid(row=2, column=1, columnspan=3 ,padx=10,pady=10)

#Extract Pages with Btn
ExtractBtn = ttk.Button(root, text="Extract", width=10, command=DoThings ,style="CSearch.TButton")
ExtractBtn.grid(row=2, column=4, padx=10, pady=10)


root.mainloop()